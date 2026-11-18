from datetime import datetime, timezone, timedelta

import aiohttp
from aiogram import Bot
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession

from config import BOT_TOKEN, CHANNEL_ID, ADMIN_IDS
from db.models import (
    Tournament, TournamentTemplate, TournamentEntry, User, UserSeasonStats,
    PointTransaction, ManualReward,
)


async def _is_subscribed(user_id: int) -> bool:
    if not CHANNEL_ID:
        return False
    url = f"https://api.telegram.org/bot{BOT_TOKEN}/getChatMember"
    async with aiohttp.ClientSession() as http:
        async with http.post(url, json={"chat_id": CHANNEL_ID, "user_id": user_id}) as resp:
            data = await resp.json()
            if not data.get("ok"):
                return False
            return data["result"]["status"] in ("member", "administrator", "creator")


async def get_active_tournaments(session: AsyncSession, season_id: int) -> list[Tournament]:
    stmt = (
        select(Tournament)
        .where(Tournament.season_id == season_id, Tournament.status == "active")
        .order_by(Tournament.id)
    )
    return list((await session.execute(stmt)).scalars())


async def add_drop_to_tournament(session: AsyncSession, season_id: int, user_id: int, final_price: int):
    if final_price <= 0:
        return
    tournaments = await get_active_tournaments(session, season_id)
    for tournament in tournaments:
        entry = (await session.execute(
            select(TournamentEntry).where(
                TournamentEntry.tournament_id == tournament.id,
                TournamentEntry.user_id == user_id,
            )
        )).scalar_one_or_none()
        if not entry:
            entry = TournamentEntry(tournament_id=tournament.id, user_id=user_id, total_score=0)
            session.add(entry)
        entry.total_score += final_price


async def start_template_tournament(session: AsyncSession, template: TournamentTemplate) -> Tournament:
    now = datetime.now(timezone.utc)
    ends = now + timedelta(hours=template.duration_hours)
    t = Tournament(
        template_id=template.id,
        season_id=template.season_id,
        name=template.name,
        starts_at=now,
        ends_at=ends,
        status="active",
        top_n=template.top_n,
        min_score=template.min_score,
        score_multiplier=template.score_multiplier or {},
        reward_config=template.reward_config or {},
        display_limit=template.display_limit,
        nickname_max_length=template.nickname_max_length,
        leaderboard_labels=template.leaderboard_labels or {},
    )
    session.add(t)
    await session.flush()
    return t


def _truncate(name: str, max_len: int) -> str:
    if len(name) <= max_len:
        return name
    return name[: max_len - 1] + "…"


async def finalize_tournament(session: AsyncSession, tournament: Tournament, bot: Bot | None = None) -> list[dict]:
    now = datetime.now(timezone.utc)

    all_entries = (await session.execute(
        select(TournamentEntry, User)
        .join(User, User.id == TournamentEntry.user_id)
        .where(TournamentEntry.tournament_id == tournament.id)
        .order_by(desc(TournamentEntry.total_score))
    )).all()

    scored = [(e, u) for (e, u) in all_entries if e.total_score >= tournament.min_score]

    winners: list[dict] = []
    rank = 0
    prev_score = None
    for idx, (entry, user) in enumerate(scored):
        if entry.total_score != prev_score:
            rank = idx + 1
        entry.rank = rank
        prev_score = entry.total_score

        if rank > tournament.top_n:
            continue

        reward_cfg = tournament.reward_config or {}
        reward = reward_cfg.get(str(rank)) or reward_cfg.get(rank) or {}
        points = int(reward.get("points", 0)) if isinstance(reward, dict) else 0
        manual_desc = reward.get("manual") if isinstance(reward, dict) else None

        if points > 0:
            stats = (await session.execute(
                select(UserSeasonStats).where(
                    UserSeasonStats.user_id == user.id,
                    UserSeasonStats.season_id == tournament.season_id,
                )
            )).scalar_one_or_none()
            if stats:
                stats.points_balance += points
                session.add(PointTransaction(
                    season_id=tournament.season_id,
                    user_id=user.id,
                    amount=points,
                    source="tournament",
                    meta={"tournament_id": tournament.id, "rank": rank},
                ))
            entry.reward_given = True

        if manual_desc:
            session.add(ManualReward(
                user_id=user.id,
                tournament_id=tournament.id,
                description=str(manual_desc),
                status="pending",
                created_by=0,
            ))

        sub = await _is_subscribed(user.id)
        winners.append({
            "rank": rank,
            "user_id": user.id,
            "username": user.username or "anonymous",
            "score": entry.total_score,
            "points_awarded": points,
            "manual": manual_desc,
            "subscribed": sub,
        })

    tournament.status = "finished"
    tournament.finalized_at = now

    if tournament.template_id:
        template = await session.get(TournamentTemplate, tournament.template_id)
        if template and template.is_active and template.is_recurring:
            template.next_start_at = _next_start(template.type, now)
        elif template:
            template.next_start_at = None

    if bot is not None:
        max_len = tournament.nickname_max_length or 15
        labels = tournament.leaderboard_labels or {}

        winners_map = {w["user_id"]: w for w in winners}
        rank_map: dict[int, int] = {}
        r = 0
        prev = None
        for idx, (e, u) in enumerate(scored):
            if e.total_score != prev:
                r = idx + 1
            rank_map[u.id] = r
            prev = e.total_score

        winners_lines_public = ["🏆 Победители:"]
        if winners:
            for w in winners:
                uname = _truncate(w["username"], max_len)
                label = labels.get(str(w["rank"]), "")
                label_str = f" [{label}]" if label else ""
                line = f"{w['rank']}.{label_str} @{uname} — {w['score']}"
                if w["points_awarded"]:
                    line += f" (+{w['points_awarded']})"
                if w["manual"]:
                    line += f" 🎁 {w['manual']}"
                winners_lines_public.append(line)
        else:
            winners_lines_public.append("нет — никто не набрал min_score")
        winners_text_public = "\n".join(winners_lines_public)

        for entry, user in all_entries:
            my_rank = rank_map.get(user.id)
            my_score = entry.total_score
            w = winners_map.get(user.id)

            lines = [
                f"🏁 Турнир «{tournament.name}» завершён",
                "",
                f"Ваше место: {my_rank if my_rank else '—'}",
                f"Ваши очки: {my_score}",
            ]
            if w:
                if w["points_awarded"]:
                    lines.append(f"Награда: +{w['points_awarded']} очков")
                if w["manual"]:
                    lines.append(f"Ручная награда: {w['manual']} (админ выдаст отдельно)")
            else:
                lines.append(f"Вы вне зоны наград (top {tournament.top_n})")
            lines.append("")
            lines.append(winners_text_public)

            try:
                await bot.send_message(user.id, "\n".join(lines))
            except Exception as e:
                print(f"[tournament] failed to send to {user.id}: {e}")

        admin_lines = [
            f"🏁 Турнир «{tournament.name}» завершён",
            f"Период: {tournament.starts_at.strftime('%d.%m %H:%M')} — {tournament.ends_at.strftime('%d.%m %H:%M')} UTC",
            f"Участников: {len(all_entries)}, в зачёте: {len(scored)}",
            "",
            "Победители:",
        ]
        if winners:
            for w in winners:
                uname = _truncate(w["username"], max_len)
                label = labels.get(str(w["rank"]), "")
                label_str = f" [{label}]" if label else ""
                line = f"{w['rank']}.{label_str} @{uname} (id: {w['user_id']}) — {w['score']}"
                if w["points_awarded"]:
                    line += f" → +{w['points_awarded']}"
                if w["manual"]:
                    line += f" · 🎁 {w['manual']}"
                line += f" · подписка: {'✅' if w.get('subscribed') else '❌'}"
                admin_lines.append(line)
        else:
            admin_lines.append("нет — никто не набрал min_score")
        admin_text = "\n".join(admin_lines)

        for aid in ADMIN_IDS:
            try:
                await bot.send_message(aid, admin_text)
            except Exception as e:
                print(f"[tournament] failed to send admin report to {aid}: {e}")

    return winners


def _next_start(ttype: str, after: datetime) -> datetime | None:
    if ttype == "daily":
        return after.replace(hour=0, minute=0, second=0, microsecond=0) + timedelta(days=1)
    if ttype == "weekly":
        days_ahead = (7 - after.weekday()) % 7 or 7
        return (after + timedelta(days=days_ahead)).replace(hour=0, minute=0, second=0, microsecond=0)
    if ttype == "monthly":
        year = after.year + (1 if after.month == 12 else 0)
        month = 1 if after.month == 12 else after.month + 1
        return after.replace(year=year, month=month, day=1, hour=0, minute=0, second=0, microsecond=0)
    if ttype == "custom":
        return after
    return None