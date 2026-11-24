import random
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
import redis.asyncio as aioredis

from config import REDIS_URL
from db.models import Case, CaseItem, Drop, UserSeasonStats, PointTransaction, ActivityRewardConfig
from services.tournament_service import add_drop_to_tournament


class CaseError(Exception):
    pass


def _roll_quality(float_val: float, cfg: ActivityRewardConfig) -> tuple[str, float]:
    if float_val >= 0.45:
        return "BS", cfg.mult_bs
    if float_val >= 0.38:
        return "WW", cfg.mult_ww
    if float_val >= 0.15:
        return "FT", cfg.mult_ft
    if float_val >= 0.07:
        return "MW", cfg.mult_mw
    return "FN", cfg.mult_fn


async def get_or_create_cfg(session: AsyncSession, season_id: int) -> ActivityRewardConfig:
    cfg = (await session.execute(
        select(ActivityRewardConfig).where(ActivityRewardConfig.season_id == season_id)
    )).scalar_one_or_none()
    if not cfg:
        cfg = ActivityRewardConfig(season_id=season_id)
        session.add(cfg)
        await session.flush()
    return cfg


async def open_case(session: AsyncSession, user_id: int, season_id: int, case_id: int):
    stmt = select(Case).where(Case.id == case_id, Case.season_id == season_id, Case.is_active)
    case = (await session.execute(stmt)).scalar_one_or_none()
    if not case:
        raise CaseError("Кейс не найден или неактивен")

        # Проверка подписки для лимитированных кейсов
    if case.is_limited:
        from services.tournament_service import _is_subscribed
        if not await _is_subscribed(user_id):
            raise CaseError("🔒 Для открытия этого кейса нужна подписка на канал.")
    # Лимитированный кейс — проверка через Redis
    r = None
    if case.is_limited and case.limit_attempts > 0:
        r = aioredis.from_url(REDIS_URL)
        key = f"case_limit:{user_id}:{case.id}"
        used = int((await r.get(key)) or 0)
        if used >= case.limit_attempts:
            await r.close()
            raise CaseError(
                f"Лимит исчерпан. Попыток: {case.limit_attempts}. "
                f"Сброс через {case.limit_period_hours} ч."
            )

    stmt = select(CaseItem).where(
        CaseItem.case_id == case.id,
        CaseItem.deleted_at.is_(None),
    )
    items = list((await session.execute(stmt)).scalars())
    if not items:
        raise CaseError("В кейсе нет предметов")

    stmt = select(UserSeasonStats).where(
        UserSeasonStats.user_id == user_id,
        UserSeasonStats.season_id == season_id,
    ).with_for_update()
    stats = (await session.execute(stmt)).scalar_one_or_none()
    if not stats:
        raise CaseError("Профиль не найден")

    # Проверка баланса — только если цена > 0
    if case.price_points > 0 and stats.points_balance < case.price_points:
        raise CaseError("Недостаточно очков")

    total_weight = sum(it.weight for it in items)
    roll = random.randint(1, total_weight)
    cumulative = 0
    chosen = items[0]
    for it in items:
        cumulative += it.weight
        if roll <= cumulative:
            chosen = it
            break

    cfg = await get_or_create_cfg(session, season_id)

    float_val = round(random.uniform(0.01, 1.0), 4)
    quality, mult = _roll_quality(float_val, cfg)

    is_stattrak = random.randint(1, 100) <= cfg.stattrak_chance
    if is_stattrak:
        mult *= cfg.stattrak_multiplier

    final_price = max(1, int(chosen.point_value * mult))

    # Списываем цену — только если > 0
    if case.price_points > 0:
        stats.points_balance -= case.price_points

    drop = Drop(
        season_id=season_id,
        user_id=user_id,
        case_id=case.id,
        item_id=chosen.id,
        float_value=float_val,
        quality=quality,
        is_stattrak=is_stattrak,
        final_price=final_price,
        is_sold=False,
    )
    session.add(drop)
    # Обновляем статистику
    stats.total_cases_opened += 1

    # Самый дорогой дроп
    if final_price > (stats.best_drop_price or 0):
        stats.best_drop_price = final_price
        stats.best_drop_name = chosen.name

    # Любимый кейс — нужно посчитать, сколько раз открывался каждый
    from sqlalchemy import func as sqlfunc
    case_counts = (await session.execute(
        select(Drop.case_id, sqlfunc.count(Drop.id).label("cnt"))
        .where(Drop.user_id == user_id, Drop.season_id == season_id)
        .group_by(Drop.case_id)
        .order_by(sqlfunc.count(Drop.id).desc())
        .limit(1)
    )).first()
    if case_counts:
        stats.favorite_case_id = case_counts[0]
        fav_case = await session.get(Case, case_counts[0])
        stats.favorite_case_name = fav_case.name if fav_case else None

    tx = PointTransaction(
        season_id=season_id,
        user_id=user_id,
        amount=-case.price_points,
        source="case_open",
        meta={"case_id": case.id, "item_id": chosen.id, "item_name": chosen.name},
    )
    session.add(tx)

    await add_drop_to_tournament(session, season_id, user_id, final_price)

    await session.commit()

    # Инкремент счётчика лимита — только после успешного дропа
    if case.is_limited and case.limit_attempts > 0 and r is not None:
        key = f"case_limit:{user_id}:{case.id}"
        ttl = case.limit_period_hours * 3600
        await r.incr(key)
        # Устанавливаем TTL при первом инкременте
        if await r.ttl(key) < 0:
            await r.expire(key, ttl)
        await r.close()

    return {
        "item_id": chosen.id,
        "item_name": chosen.name,
        "rarity": chosen.rarity,
        "point_value": chosen.point_value,
        "image_url": chosen.image_url,
        "float_value": float_val,
        "quality": quality,
        "is_stattrak": is_stattrak,
        "final_price": final_price,
        "balance_after": stats.points_balance,
        "drop_id": drop.id,
    }
    stmt = select(Case).where(Case.id == case_id, Case.season_id == season_id, Case.is_active)
    case = (await session.execute(stmt)).scalar_one_or_none()
    if not case:
        raise CaseError("Кейс не найден или неактивен")

    stmt = select(CaseItem).where(
        CaseItem.case_id == case.id,
        CaseItem.deleted_at.is_(None),
    )
    items = list((await session.execute(stmt)).scalars())
    if not items:
        raise CaseError("В кейсе нет предметов")

    stmt = select(UserSeasonStats).where(
        UserSeasonStats.user_id == user_id,
        UserSeasonStats.season_id == season_id,
    ).with_for_update()
    stats = (await session.execute(stmt)).scalar_one_or_none()
    if not stats:
        raise CaseError("Профиль не найден")
    if stats.points_balance < case.price_points:
        raise CaseError("Недостаточно очков")

    total_weight = sum(it.weight for it in items)
    roll = random.randint(1, total_weight)
    cumulative = 0
    chosen = items[0]
    for it in items:
        cumulative += it.weight
        if roll <= cumulative:
            chosen = it
            break

    cfg = await get_or_create_cfg(session, season_id)

    float_val = round(random.uniform(0.01, 1.0), 4)
    quality, mult = _roll_quality(float_val, cfg)

    is_stattrak = random.randint(1, 100) <= cfg.stattrak_chance
    if is_stattrak:
        mult *= cfg.stattrak_multiplier

    final_price = max(1, int(chosen.point_value * mult))

    stats.points_balance -= case.price_points

    drop = Drop(
        season_id=season_id,
        user_id=user_id,
        case_id=case.id,
        item_id=chosen.id,
        float_value=float_val,
        quality=quality,
        is_stattrak=is_stattrak,
        final_price=final_price,
        is_sold=False,
    )
    session.add(drop)

    tx = PointTransaction(
        season_id=season_id,
        user_id=user_id,
        amount=-case.price_points,
        source="case_open",
        meta={"case_id": case.id, "item_id": chosen.id, "item_name": chosen.name},
    )
    session.add(tx)

    await add_drop_to_tournament(session, season_id, user_id, final_price)

    await session.commit()

    return {
        "item_id": chosen.id,
        "item_name": chosen.name,
        "rarity": chosen.rarity,
        "point_value": chosen.point_value,
        "image_url": chosen.image_url,
        "float_value": float_val,
        "quality": quality,
        "is_stattrak": is_stattrak,
        "final_price": final_price,
        "balance_after": stats.points_balance,
        "drop_id": drop.id,
    }