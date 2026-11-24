from datetime import datetime, timezone, timedelta

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy import select, desc, func
from sqlalchemy.ext.asyncio import AsyncSession


import aiohttp
import redis.asyncio as aioredis

from config import BOT_TOKEN, CHANNEL_ID, CHANNEL_LINK, REDIS_URL
from db.base import get_session
from db.models import (
    Season, User, UserSeasonStats, Case, CaseItem, Drop, PointTransaction,
    Tournament, TournamentEntry,
)
from services.case_service import open_case, CaseError
from telegram_init_data import validate, parse

router = APIRouter(prefix="/api/webapp")


def verify_init_data(init_data: str) -> dict:
    try:
        validate(init_data, BOT_TOKEN)
        return parse(init_data)
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Invalid initData: {e}")


class OpenCasePayload(BaseModel):
    initData: str
    case_id: int


class ProfilePayload(BaseModel):
    initData: str


class DailyBonusPayload(BaseModel):
    initData: str


class ReferralPayload(BaseModel):
    initData: str


class SellItemPayload(BaseModel):
    initData: str
    drop_id: int


async def get_or_create_user_and_season(session: AsyncSession, user_data: dict):
    tg_user = user_data.get("user", {})
    user_id = tg_user.get("id")
    if not user_id:
        raise HTTPException(status_code=400, detail="No user in initData")

    user = await session.get(User, user_id)
    if not user:
        user = User(
            id=user_id,
            username=tg_user.get("username"),
            first_name=tg_user.get("first_name"),
        )
        session.add(user)
        await session.flush()

    if user.is_banned:
        raise HTTPException(status_code=403, detail="Banned")

    if user.role != "admin" and CHANNEL_ID:
        r = aioredis.from_url(REDIS_URL)
        try:
            cache_key = f"sub_check:{user_id}"
            cached = await r.get(cache_key)
            if cached is not None:
                is_sub = cached.decode() == "1"
            else:
                async with aiohttp.ClientSession() as http:
                    async with http.post(
                        f"https://api.telegram.org/bot{BOT_TOKEN}/getChatMember",
                        json={"chat_id": CHANNEL_ID, "user_id": user_id},
                    ) as resp:
                        data = await resp.json()
                if data.get("ok"):
                    status = data["result"]["status"]
                    is_sub = status in ("member", "administrator", "creator")
                else:
                    print(f"[subscription] getChatMember error: {data}")
                    is_sub = False
                await r.set(cache_key, "1" if is_sub else "0", ex=300)
        finally:
            await r.close()

        if not is_sub:
            raise HTTPException(status_code=403, detail="Subscription required")

    season_stmt = select(Season).where(Season.status == "active").order_by(Season.id.desc())
    season = (await session.execute(season_stmt)).scalar_one_or_none()
    if not season:
        raise HTTPException(status_code=500, detail="Нет активного сезона")

    stats = (await session.execute(
        select(UserSeasonStats).where(
            UserSeasonStats.user_id == user_id,
            UserSeasonStats.season_id == season.id,
        )
    )).scalar_one_or_none()
    if not stats:
        stats = UserSeasonStats(user_id=user_id, season_id=season.id, points_balance=500)
        session.add(stats)
        await session.flush()

    await session.commit()
    return user, season, stats


async def get_or_create_invite_link(user_id: int) -> str | None:
    if not CHANNEL_ID and not getattr(__import__("config"), "CHAT_ID", None):
        pass
    from config import CHAT_ID
    if not CHAT_ID:
        return None

    r = aioredis.from_url(REDIS_URL)
    try:
        cached = await r.get(f"ref_link:{user_id}")
        if cached:
            return cached.decode()

        async with aiohttp.ClientSession() as http:
            async with http.post(
                f"https://api.telegram.org/bot{BOT_TOKEN}/createChatInviteLink",
                json={"chat_id": CHAT_ID, "name": f"ref_{user_id}"},
            ) as resp:
                data = await resp.json()
                print(f"[referral] createChatInviteLink response: {data}")

        if not data.get("ok"):
            return None

        link = data["result"]["invite_link"]
        await r.set(f"ref_link:{user_id}", link, ex=7 * 24 * 3600)
        return link
    finally:
        await r.close()


@router.post("/profile")
async def profile(payload: ProfilePayload, session: AsyncSession = Depends(get_session)):
    user_data = verify_init_data(payload.initData)
    user, season, stats = await get_or_create_user_and_season(session, user_data)

    # Определяем точку отсчета для статистики
    reset_filter = []
    if stats.stats_reset_at:
        reset_filter.append(Drop.rolled_at >= stats.stats_reset_at)

    # 1. Количество открытых кейсов
    total_opened = (await session.execute(
        select(func.count(Drop.id)).where(
            Drop.user_id == user.id, 
            Drop.season_id == season.id,
            *reset_filter
        )
    )).scalar_one() or 0

    # 2. Любимый кейс
    fav_case_row = (await session.execute(
        select(Case.name, func.count(Drop.id).label("cnt"))
        .join(Drop, Drop.case_id == Case.id)
        .where(Drop.user_id == user.id, Drop.season_id == season.id, *reset_filter)
        .group_by(Case.name)
        .order_by(func.count(Drop.id).desc())
        .limit(1)
    )).first()
    favorite_case_name = fav_case_row[0] if fav_case_row else None

    # 3. Самый дорогой дроп
    best_drop_row = (await session.execute(
        select(CaseItem.name, Drop.final_price)
        .join(CaseItem, Drop.item_id == CaseItem.id)
        .where(Drop.user_id == user.id, Drop.season_id == season.id, *reset_filter)
        .order_by(Drop.final_price.desc())
        .limit(1)
    )).first()
    
    best_drop_name = best_drop_row[0] if best_drop_row else None
    best_drop_price = best_drop_row[1] if best_drop_row else 0

    return {
        "user_id": user.id,
        "username": user.username,
        "first_name": user.first_name,
        "balance": stats.points_balance,
        "streak": stats.streak_days,
        "season_name": season.name,
        "total_cases_opened": total_opened,
        "favorite_case": favorite_case_name,
        "best_drop_price": best_drop_price,
        "best_drop_name": best_drop_name,
    }


@router.post("/open-case")
async def api_open_case(payload: OpenCasePayload, session: AsyncSession = Depends(get_session)):
    user_data = verify_init_data(payload.initData)
    user, season, _ = await get_or_create_user_and_season(session, user_data)
    try:
        result = await open_case(session, user.id, season.id, payload.case_id)
    except CaseError as e:
        raise HTTPException(status_code=400, detail=str(e))
    return result


@router.post("/daily-bonus")
async def daily_bonus(payload: DailyBonusPayload, session: AsyncSession = Depends(get_session)):
    user_data = verify_init_data(payload.initData)
    user, season, stats = await get_or_create_user_and_season(session, user_data)

    now = datetime.now(timezone.utc)
    last = stats.last_daily_at

    if last is not None:
        if last.date() == now.date():
            raise HTTPException(status_code=400, detail="Бонус уже получен сегодня")
        if last.date() == (now - timedelta(days=1)).date():
            stats.streak_days += 1
        else:
            stats.streak_days = 1
    else:
        stats.streak_days = 1

    base = 10
    streak_bonus = min(stats.streak_days * 5, 50)
    reward = base + streak_bonus

    stats.points_balance += reward
    stats.last_daily_at = now

    tx = PointTransaction(
        season_id=season.id,
        user_id=user.id,
        amount=reward,
        source="daily",
        meta={"streak": stats.streak_days, "base": base, "bonus": streak_bonus},
    )
    session.add(tx)
    await session.commit()

    next_day = (now + timedelta(days=1)).replace(hour=0, minute=0, second=0, microsecond=0)

    return {
        "reward": reward,
        "streak": stats.streak_days,
        "balance_after": stats.points_balance,
        "next_available_at": int(next_day.timestamp() * 1000),
    }


@router.get("/cases")
async def list_cases(
    initData: str | None = None,
    session: AsyncSession = Depends(get_session),
):
    season = (await session.execute(
        select(Season).where(Season.status == "active").order_by(Season.id.desc())
    )).scalar_one_or_none()
    if not season:
        return {"cases": []}

    user_id = None
    if initData:
        try:
            user_data = verify_init_data(initData)
            user_id = user_data.get("user", {}).get("id")
        except Exception:
            pass

    cases = (await session.execute(
        select(Case).where(Case.season_id == season.id, Case.is_active).order_by(Case.id.desc())
    )).scalars().all()

    r = aioredis.from_url(REDIS_URL) if user_id else None
    result = []
    try:
        for c in cases:
            items = (await session.execute(
                select(CaseItem).where(CaseItem.case_id == c.id, CaseItem.deleted_at.is_(None))
            )).scalars().all()
            total_weight = sum(it.weight for it in items) or 1

            remaining = None
            if c.is_limited and c.limit_attempts > 0 and user_id and r:
                used = int((await r.get(f"case_limit:{user_id}:{c.id}")) or 0)
                remaining = max(0, c.limit_attempts - used)

            result.append({
                "id": c.id,
                "name": c.name,
                "price": c.price_points,
                "image_url": c.image_url,
                "is_limited": bool(c.is_limited),
                "limit_attempts": c.limit_attempts,
                "limit_period_hours": c.limit_period_hours,
                "remaining_attempts": remaining,
                "items": [
                    {
                        "id": it.id,
                        "name": it.name,
                        "rarity": it.rarity,
                        "chance": round(it.weight / total_weight * 100, 2),
                        "pointValue": it.point_value,
                        "image_url": it.image_url,
                    }
                    for it in items
                ],
            })
    finally:
        if r:
            await r.close()

    return {"cases": result}


@router.get("/feed")
async def feed(limit: int = 20, session: AsyncSession = Depends(get_session)):
    season = (await session.execute(
        select(Season).where(Season.status == "active").order_by(Season.id.desc())
    )).scalar_one_or_none()
    if not season:
        return {"drops": []}

    stmt = (
        select(Drop, User.username, CaseItem.name, CaseItem.rarity, Case.name, CaseItem.image_url)
        .join(User, User.id == Drop.user_id)
        .join(CaseItem, CaseItem.id == Drop.item_id)
        .join(Case, Case.id == Drop.case_id)
        .where(Drop.season_id == season.id)
        .order_by(desc(Drop.rolled_at))
        .limit(limit)
    )
    rows = (await session.execute(stmt)).all()
    return {
        "drops": [
            {
                "id": d.id,
                "username": u or "anonymous",
                "itemName": item_name,
                "rarity": rarity,
                "caseName": case_name,
                "rolledAt": int(d.rolled_at.timestamp() * 1000),
                "image_url": item_image,
            }
            for d, u, item_name, rarity, case_name, item_image in rows
        ]
    }


@router.get("/leaderboard")
async def leaderboard(limit: int = 10, session: AsyncSession = Depends(get_session)):
    season = (await session.execute(
        select(Season).where(Season.status == "active").order_by(Season.id.desc())
    )).scalar_one_or_none()
    if not season:
        return {"entries": []}

    stmt = (
        select(UserSeasonStats, User.username)
        .join(User, User.id == UserSeasonStats.user_id)
        .where(UserSeasonStats.season_id == season.id)
        .order_by(desc(UserSeasonStats.total_quality_score))
        .limit(limit)
    )
    rows = (await session.execute(stmt)).all()
    return {
        "entries": [
            {
                "userId": s.user_id,
                "username": u or "anonymous",
                "score": s.total_quality_score,
                "rank": i + 1,
            }
            for i, (s, u) in enumerate(rows)
        ]
    }


@router.get("/tournament")
async def current_tournaments(session: AsyncSession = Depends(get_session)):
    season = (await session.execute(
        select(Season).where(Season.status == "active").order_by(Season.id.desc())
    )).scalar_one_or_none()
    if not season:
        return {"tournaments": []}

    tournaments = (await session.execute(
        select(Tournament).where(
            Tournament.season_id == season.id,
            Tournament.status == "active",
        ).order_by(Tournament.id)
    )).scalars().all()

    result = []
    for t in tournaments:
        rows = (await session.execute(
            select(TournamentEntry, User.username)
            .join(User, User.id == TournamentEntry.user_id)
            .where(TournamentEntry.tournament_id == t.id)
            .order_by(TournamentEntry.total_score.desc())
            .limit(t.display_limit or 10)
        )).all()
        result.append({
            "id": t.id,
            "name": t.name,
            "starts_at": int(t.starts_at.timestamp() * 1000),
            "ends_at": int(t.ends_at.timestamp() * 1000),
            "top_n": t.top_n,
            "nickname_max_length": t.nickname_max_length or 15,
            "leaderboard_labels": t.leaderboard_labels or {},
            "entries": [
                {
                    "userId": e.user_id,
                    "username": u or "anonymous",
                    "score": e.total_score,
                    "rank": i + 1,
                }
                for i, (e, u) in enumerate(rows)
            ],
        })

    return {"tournaments": result}

@router.get("/tournaments")
async def list_tournaments(session: AsyncSession = Depends(get_session)):
    season = (await session.execute(
        select(Season).where(Season.status == "active").order_by(Season.id.desc())
    )).scalar_one_or_none()
    if not season:
        return {"tournaments": []}

    rows = (await session.execute(
        select(Tournament).where(Tournament.season_id == season.id).order_by(Tournament.id.desc())
    )).scalars().all()

    return {"tournaments": [
        {
            "id": t.id,
            "name": t.name,
            "status": t.status,
            "starts_at": int(t.starts_at.timestamp() * 1000),
            "ends_at": int(t.ends_at.timestamp() * 1000),
            "top_n": t.top_n,
        }
        for t in rows
    ]}


@router.get("/tournament/{tournament_id}")
async def tournament_detail(tournament_id: int, session: AsyncSession = Depends(get_session)):
    t = await session.get(Tournament, tournament_id)
    if not t:
        raise HTTPException(status_code=404, detail="Tournament not found")

    rows = (await session.execute(
        select(TournamentEntry, User.username)
        .join(User, User.id == TournamentEntry.user_id)
        .where(TournamentEntry.tournament_id == t.id)
        .order_by(TournamentEntry.total_score.desc())
        .limit(t.display_limit or 50)
    )).all()

    return {
        "tournament": {
            "id": t.id,
            "name": t.name,
            "status": t.status,
            "starts_at": int(t.starts_at.timestamp() * 1000),
            "ends_at": int(t.ends_at.timestamp() * 1000),
            "top_n": t.top_n,
            "min_score": t.min_score,
            "nickname_max_length": t.nickname_max_length or 15,
            "leaderboard_labels": t.leaderboard_labels or {},
            "entries": [
                {"userId": e.user_id, "username": u or "anonymous", "score": e.total_score, "rank": e.rank or (i + 1)}
                for i, (e, u) in enumerate(rows)
            ],
        }
    }


@router.post("/referral")
async def get_referral(payload: ReferralPayload, session: AsyncSession = Depends(get_session)):
    user_data = verify_init_data(payload.initData)
    user, season, _ = await get_or_create_user_and_season(session, user_data)

    link = await get_or_create_invite_link(user.id)

    invited_count = (await session.execute(
        select(func.count(User.id)).where(User.referred_by == user.id)
    )).scalar_one()

    earned = (await session.execute(
        select(func.coalesce(func.sum(PointTransaction.amount), 0)).where(
            PointTransaction.season_id == season.id,
            PointTransaction.user_id == user.id,
            PointTransaction.source == "referral",
        )
    )).scalar_one()

    if not link:
        return {
            "link": None,
            "invited_count": int(invited_count or 0),
            "earned_points": int(earned or 0),
            "error": "Не удалось создать инвайт-ссылку.",
        }

    return {
        "link": link,
        "invited_count": int(invited_count or 0),
        "earned_points": int(earned or 0),
    }


@router.post("/inventory")
async def get_inventory(payload: ProfilePayload, session: AsyncSession = Depends(get_session)):
    user_data = verify_init_data(payload.initData)
    user, season, _ = await get_or_create_user_and_season(session, user_data)

    rows = (await session.execute(
        select(Drop, CaseItem.name, CaseItem.rarity, CaseItem.image_url)
        .join(CaseItem, CaseItem.id == Drop.item_id)
        .where(
            Drop.user_id == user.id,
            Drop.season_id == season.id,
            Drop.is_sold.is_(False),
        )
        .order_by(desc(Drop.rolled_at))
    )).all()

    return {
        "items": [
            {
                "id": d.id,
                "name": name,
                "rarity": rarity,
                "image_url": img,
                "quality": d.quality,
                "is_stattrak": d.is_stattrak,
                "sell_price": d.final_price,
                "rolled_at": int(d.rolled_at.timestamp() * 1000),
            }
            for d, name, rarity, img in rows
        ]
    }


@router.post("/sell-item")
async def sell_item(payload: SellItemPayload, session: AsyncSession = Depends(get_session)):
    user_data = verify_init_data(payload.initData)
    user, season, stats = await get_or_create_user_and_season(session, user_data)

    drop = (await session.execute(
        select(Drop).where(
            Drop.id == payload.drop_id,
            Drop.user_id == user.id,
            Drop.is_sold.is_(False),
        )
    )).scalar_one_or_none()
    if not drop:
        raise HTTPException(status_code=400, detail="Предмет не найден или уже продан")

    price = drop.final_price or 0
    drop.is_sold = True

    # вычитаем стоимость только из тех турниров, где предмет участвовал (выпал после старта)
    from db.models import Tournament, TournamentEntry
    active_tournaments = (await session.execute(
        select(Tournament).where(
            Tournament.season_id == season.id,
            Tournament.status == "active",
        )
    )).scalars().all()

    for t in active_tournaments:
        if drop.rolled_at >= t.starts_at:
            entry = (await session.execute(
                select(TournamentEntry).where(
                    TournamentEntry.tournament_id == t.id,
                    TournamentEntry.user_id == user.id,
                )
            )).scalar_one_or_none()
            if entry:
                entry.total_score = max(0, entry.total_score - price)

    stats.points_balance += price

    session.add(PointTransaction(
        season_id=season.id,
        user_id=user.id,
        amount=price,
        source="sell_item",
        meta={"drop_id": drop.id},
    ))
    await session.commit()

    return {"ok": True, "price": price, "new_balance": stats.points_balance}



@router.get("/rules")
async def get_rules(session: AsyncSession = Depends(get_session)):
    season = (await session.execute(
        select(Season).where(Season.status == "active").order_by(Season.id.desc())
    )).scalar_one_or_none()
    if not season:
        return {"enabled": False, "text": ""}
    return {
        "enabled": bool(season.rules_enabled),
        "text": season.rules_text or "",
    }


@router.post("/tasks")
async def get_tasks(payload: ProfilePayload, session: AsyncSession = Depends(get_session)):
    user_data = verify_init_data(payload.initData)
    user, season, _ = await get_or_create_user_and_season(session, user_data)

    link = await get_or_create_invite_link(user.id)

    invited_count = (await session.execute(
        select(func.count(User.id)).where(User.referred_by == user.id)
    )).scalar_one()
    earned = (await session.execute(
        select(func.coalesce(func.sum(PointTransaction.amount), 0)).where(
            PointTransaction.season_id == season.id,
            PointTransaction.user_id == user.id,
            PointTransaction.source == "referral",
        )
    )).scalar_one()

    from services.activity_service import get_or_create_config
    cfg = await get_or_create_config(session, season.id)
    await session.commit()

    subscribed = False
    if CHANNEL_ID:
        r = aioredis.from_url(REDIS_URL)
        try:
            cache_key = f"sub_check:{user.id}"
            cached = await r.get(cache_key)
            if cached is not None:
                subscribed = cached.decode() == "1"
            else:
                async with aiohttp.ClientSession() as http:
                    async with http.post(
                        f"https://api.telegram.org/bot{BOT_TOKEN}/getChatMember",
                        json={"chat_id": CHANNEL_ID, "user_id": user.id},
                    ) as resp:
                        data = await resp.json()
                if data.get("ok"):
                    subscribed = data["result"]["status"] in ("member", "administrator", "creator")
                await r.set(cache_key, "1" if subscribed else "0", ex=300)
        finally:
            await r.close()

    sub_awarded = (await session.execute(
        select(func.count(PointTransaction.id)).where(
            PointTransaction.season_id == season.id,
            PointTransaction.user_id == user.id,
            PointTransaction.source == "subscription",
        )
    )).scalar_one() > 0

    return {
        "referral": {
            "link": link,
            "invited_count": int(invited_count or 0),
            "earned_points": int(earned or 0),
            "points_per_invite": cfg.points_referral,
        },
        "subscription": {
            "channel_link": CHANNEL_LINK,
            "points": cfg.points_subscription,
            "subscribed": subscribed,
            "awarded": sub_awarded,
        },
    }


@router.post("/claim-subscription")
async def claim_subscription(payload: ProfilePayload, session: AsyncSession = Depends(get_session)):
    user_data = verify_init_data(payload.initData)
    user, season, _ = await get_or_create_user_and_season(session, user_data)

    subscribed = False
    if CHANNEL_ID:
        async with aiohttp.ClientSession() as http:
            async with http.post(
                f"https://api.telegram.org/bot{BOT_TOKEN}/getChatMember",
                json={"chat_id": CHANNEL_ID, "user_id": user.id},
            ) as resp:
                data = await resp.json()
        if data.get("ok"):
            subscribed = data["result"]["status"] in ("member", "administrator", "creator")

    if not subscribed:
        raise HTTPException(status_code=400, detail="Вы не подписаны на канал")

    from services.activity_service import reward_subscription
    awarded = await reward_subscription(session, season.id, user.id)
    await session.commit()

    return {"awarded": awarded > 0, "points": awarded}