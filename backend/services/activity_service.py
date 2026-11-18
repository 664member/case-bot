from datetime import datetime, timezone, date

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from redis.asyncio import Redis

from db.models import (
    ActivityRewardConfig, UserSeasonStats, PointTransaction,
)


async def get_or_create_config(session: AsyncSession, season_id: int) -> ActivityRewardConfig:
    cfg = (await session.execute(
        select(ActivityRewardConfig).where(ActivityRewardConfig.season_id == season_id)
    )).scalar_one_or_none()
    if not cfg:
        cfg = ActivityRewardConfig(season_id=season_id)
        session.add(cfg)
        await session.flush()
    return cfg


async def _daily_count(session: AsyncSession, season_id: int, user_id: int, source: str) -> int:
    today_start = datetime.combine(date.today(), datetime.min.time()).replace(tzinfo=timezone.utc)
    cnt = (await session.execute(
        select(func.count(PointTransaction.id)).where(
            PointTransaction.season_id == season_id,
            PointTransaction.user_id == user_id,
            PointTransaction.source == source,
            PointTransaction.created_at >= today_start,
        )
    )).scalar_one()
    return int(cnt or 0)


async def _add_points(
    session: AsyncSession, season_id: int, user_id: int, amount: int, source: str,
    meta: dict | None = None,
) -> bool:
    if amount <= 0:
        return False
    stats = (await session.execute(
        select(UserSeasonStats).where(
            UserSeasonStats.season_id == season_id,
            UserSeasonStats.user_id == user_id,
        )
    )).scalar_one_or_none()
    if not stats:
        return False
    stats.points_balance += amount
    session.add(PointTransaction(
        season_id=season_id,
        user_id=user_id,
        amount=amount,
        source=source,
        meta=meta or {},
    ))
    return True


async def reward_comment(
    session: AsyncSession, redis: Redis, season_id: int, user_id: int, text: str,
) -> int:
    cfg = await get_or_create_config(session, season_id)
    text = text.strip()

    if len(text) < cfg.min_comment_length:
        return 0

    # кулдаун
    if cfg.comment_cooldown_seconds > 0:
        key = f"comment_cd:{season_id}:{user_id}"
        if await redis.exists(key):
            return 0
        await redis.set(key, "1", ex=cfg.comment_cooldown_seconds)

    # дубликаты
    if cfg.block_duplicate_comments:
        key = f"last_comment:{season_id}:{user_id}"
        prev = await redis.get(key)
        if prev and prev.decode() == text:
            return 0
        await redis.set(key, text, ex=3600)

    # дневной лимит
    if cfg.daily_limit_comment > 0:
        used = await _daily_count(session, season_id, user_id, "comment")
        if used >= cfg.daily_limit_comment:
            return 0

    ok = await _add_points(session, season_id, user_id, cfg.points_comment, "comment", {"len": len(text)})
    return cfg.points_comment if ok else 0


async def reward_subscription(session: AsyncSession, season_id: int, user_id: int) -> int:
    cfg = await get_or_create_config(session, season_id)
    existing = (await session.execute(
        select(PointTransaction.id).where(
            PointTransaction.season_id == season_id,
            PointTransaction.user_id == user_id,
            PointTransaction.source == "subscription",
        ).limit(1)
    )).scalar_one_or_none()
    if existing:
        return 0
    ok = await _add_points(session, season_id, user_id, cfg.points_subscription, "subscription")
    return cfg.points_subscription if ok else 0


async def reward_referral(session: AsyncSession, season_id: int, referrer_id: int, referred_id: int) -> int:
    cfg = await get_or_create_config(session, season_id)
    existing = (await session.execute(
        select(PointTransaction.id).where(
            PointTransaction.season_id == season_id,
            PointTransaction.user_id == referrer_id,
            PointTransaction.source == "referral",
            PointTransaction.meta["referred_id"].astext == str(referred_id),
        ).limit(1)
    )).scalar_one_or_none()
    if existing:
        return 0
    ok = await _add_points(
        session, season_id, referrer_id, cfg.points_referral, "referral",
        {"referred_id": referred_id},
    )
    return cfg.points_referral if ok else 0


async def qualifies_for_referral(session: AsyncSession, season_id: int, user_id: int) -> bool:
    cnt = (await session.execute(
        select(func.count(PointTransaction.id)).where(
            PointTransaction.season_id == season_id,
            PointTransaction.user_id == user_id,
            PointTransaction.source.in_(["comment", "case_open"]),
        )
    )).scalar_one()
    return int(cnt or 0) > 0