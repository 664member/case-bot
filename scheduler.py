from datetime import datetime, timezone

from aiogram import Bot
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from sqlalchemy import select

from config import ADMIN_IDS
from db.base import SessionLocal
from db.models import Tournament, TournamentTemplate, Season, User
from services.tournament_service import (
    start_template_tournament, finalize_tournament, _next_start,
)

scheduler = AsyncIOScheduler(timezone="UTC")


def _fmt_dt(dt: datetime) -> str:
    return dt.strftime("%d.%m.%Y %H:%M UTC")


async def report_to_admins(bot: Bot, tournament: Tournament, winners: list[dict]):
    if not winners:
        text = f"🏁 Турнир «{tournament.name}» завершён. Победителей нет (никто не набрал min_score)."
        for aid in ADMIN_IDS:
            try:
                await bot.send_message(aid, text)
            except Exception:
                pass
        return

    lines = [
        f"🏁 Турнир «{tournament.name}» завершён",
        f"Период: {_fmt_dt(tournament.starts_at)} — {_fmt_dt(tournament.ends_at)}",
        "",
        "Победители:",
    ]
    for w in winners:
        line = f"{w['rank']}. @{w['username']} (id: {w['user_id']}) — {w['score']} очков"
        if w["points_awarded"]:
            line += f" → начислено {w['points_awarded']}"
        if w["manual"]:
            line += f" → вручную: {w['manual']}"
        lines.append(line)
    text = "\n".join(lines)
    for aid in ADMIN_IDS:
        try:
            await bot.send_message(aid, text)
        except Exception:
            pass


async def tick(bot: Bot):
    now = datetime.now(timezone.utc)
    async with SessionLocal() as session:
        # 1. Запуск турниров по шаблонам
        # Важно: не фильтруем по is_recurring.
        # Повторяющиеся шаблоны всегда имеют next_start_at, а разовые (custom)
        # тоже должны стартовать один раз — им next_start_at обнуляется после старта.
        templates = (await session.execute(
            select(TournamentTemplate).where(
                TournamentTemplate.is_active.is_(True),
                TournamentTemplate.next_start_at.is_not(None),
                TournamentTemplate.next_start_at <= now,
            )
        )).scalars().all()

        for tpl in templates:
            season = await session.get(Season, tpl.season_id)
            if not season or season.status != "active":
                continue
            t = await start_template_tournament(session, tpl)
            tpl.next_start_at = _next_start(tpl.type, now) if tpl.type in ("daily", "weekly", "monthly") else None
            await session.commit()
            print(f"[scheduler] started tournament {t.id} «{t.name}»")

        # 2. Финализация истёкших
        expired = (await session.execute(
            select(Tournament).where(
                Tournament.status == "active",
                Tournament.ends_at <= now,
            )
        )).scalars().all()

        for t in expired:
            winners = await finalize_tournament(session, t)
            await session.commit()
            print(f"[scheduler] finalized tournament {t.id} «{t.name}», winners: {len(winners)}")
            await report_to_admins(bot, t, winners)


def start_scheduler(bot: Bot):
    scheduler.add_job(tick, "interval", minutes=1, args=[bot], id="tournament_tick", replace_existing=True)
    scheduler.start()
    print("[scheduler] started")


def stop_scheduler():
    try:
        scheduler.shutdown(wait=False)
    except Exception:
        pass