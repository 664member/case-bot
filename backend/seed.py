import asyncio
from sqlalchemy import select

from db.base import SessionLocal, init_db
from db.models import Season, Case, CaseItem


async def seed():
    await init_db()
    async with SessionLocal() as session:
        season = (await session.execute(select(Season).where(Season.status == "active"))).scalar_one_or_none()
        if not season:
            season = Season(chat_id=0, name="Сезон 1 — Старт", status="active")
            session.add(season)
            await session.flush()

        existing = (await session.execute(select(Case).where(Case.season_id == season.id))).scalars().all()
        if existing:
            print("Кейсы уже есть, пропускаем.")
            await session.commit()
            return

        neon = Case(season_id=season.id, name="Неоновый", price_points=120)
        session.add(neon)
        await session.flush()
        session.add_all([
            CaseItem(case_id=neon.id, name="Серый болт", rarity="Common", weight=65, quality_score=1, point_value=5),
            CaseItem(case_id=neon.id, name="Синий клинок", rarity="Rare", weight=25, quality_score=5, point_value=40),
            CaseItem(case_id=neon.id, name="Пурпурный шар", rarity="Epic", weight=8, quality_score=20, point_value=150),
            CaseItem(case_id=neon.id, name="Золотой череп", rarity="Legendary", weight=2, quality_score=100, point_value=600),
        ])

        gold = Case(season_id=season.id, name="Золотой", price_points=300)
        session.add(gold)
        await session.flush()
        session.add_all([
            CaseItem(case_id=gold.id, name="Медный диск", rarity="Common", weight=50, quality_score=1, point_value=15),
            CaseItem(case_id=gold.id, name="Серебряный кубок", rarity="Rare", weight=35, quality_score=5, point_value=80),
            CaseItem(case_id=gold.id, name="Платиновое кольцо", rarity="Epic", weight=12, quality_score=20, point_value=400),
            CaseItem(case_id=gold.id, name="Корона", rarity="Legendary", weight=3, quality_score=100, point_value=1500),
        ])

        await session.commit()
        print("Сезон и кейсы созданы.")


if __name__ == "__main__":
    asyncio.run(seed())