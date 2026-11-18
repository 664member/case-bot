import asyncio
from contextlib import asynccontextmanager
from logging_setup import setup_logging
setup_logging()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from aiogram import Bot, Dispatcher
from aiogram.fsm.storage.redis import RedisStorage
from redis.asyncio import Redis

from config import BOT_TOKEN, ADMIN_IDS, REDIS_URL
from db.base import init_db, SessionLocal
from db.models import User
from api.routes import router
from bot.handlers import router as bot_router
from bot.middlewares import (
    ResetFsmOnCommandMiddleware,
    SubscriptionGateMiddleware,
    BanMiddleware,
    PrivateOnlyCommandsMiddleware,
)
from services.scheduler import start_scheduler, stop_scheduler


from fastapi.staticfiles import StaticFiles
from pathlib import Path


STATIC_DIR = Path(__file__).parent / "static"
STATIC_DIR.mkdir(exist_ok=True)
(STATIC_DIR / "images").mkdir(exist_ok=True)


bot = Bot(token=BOT_TOKEN)
redis_client = Redis.from_url(REDIS_URL)
storage = RedisStorage(redis=redis_client)
dp = Dispatcher(storage=storage)
dp["redis"] = redis_client

# порядок middleware важен:
# 1. PrivateOnlyCommandsMiddleware — блокирует команды вне ЛС (до всего)
# 2. BanMiddleware — блокирует забаненных (до подписки)
# 3. ResetFsmOnCommandMiddleware — сбрасывает FSM при новой команде
# 4. SubscriptionGateMiddleware — проверка подписки (inner, чтобы ловить callbacks)
dp.message.outer_middleware(PrivateOnlyCommandsMiddleware())
dp.message.outer_middleware(BanMiddleware())
dp.message.outer_middleware(ResetFsmOnCommandMiddleware())
dp.message.middleware(SubscriptionGateMiddleware())

dp.callback_query.outer_middleware(BanMiddleware())
dp.callback_query.middleware(SubscriptionGateMiddleware())

dp.include_router(bot_router)



def _log_polling_error(task: asyncio.Task):
    if task.cancelled():
        print("POLLING: task cancelled")
        return
    exc = task.exception()
    if exc:
        print(f"POLLING CRASHED: {type(exc).__name__}: {exc}")
    else:
        print("POLLING: finished without exception")


async def promote_admins():
    if not ADMIN_IDS:
        print("ADMIN_IDS пуст — админы не назначены")
        return
    async with SessionLocal() as session:
        for aid in ADMIN_IDS:
            user = await session.get(User, aid)
            if user:
                user.role = "admin"
            else:
                session.add(User(id=aid, role="admin"))
        await session.commit()
    print(f"ADMIN_IDS применены: {ADMIN_IDS}")


@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    await promote_admins()

    polling_task = asyncio.create_task(
        dp.start_polling(bot, allowed_updates=["message", "callback_query", "chat_member"])
    )
    polling_task.add_done_callback(_log_polling_error)

    start_scheduler(bot)

    yield

    stop_scheduler()
    polling_task.cancel()
    try:
        await polling_task
    except asyncio.CancelledError:
        pass
    await bot.session.close()
    await redis_client.close()


app = FastAPI(lifespan=lifespan)

STATIC_DIR = Path(__file__).parent / "static"
STATIC_DIR.mkdir(exist_ok=True)
(STATIC_DIR / "images").mkdir(exist_ok=True)

app.mount("/static", StaticFiles(directory=str(STATIC_DIR)), name="static")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)


@app.get("/health")
async def health():
    return {"status": "ok"}