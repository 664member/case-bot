import os
from dotenv import load_dotenv

load_dotenv()

BOT_TOKEN = os.getenv("BOT_TOKEN")
if not BOT_TOKEN:
    raise RuntimeError("BOT_TOKEN не найден в .env")

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql+asyncpg://casebot:casebot_dev_pass@localhost:5432/casebot",
)

WEBAPP_URL = os.getenv("WEBAPP_URL", "http://localhost:3000")

ADMIN_IDS = [int(x) for x in os.getenv("ADMIN_IDS", "").split(",") if x.strip()]

REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")

CHAT_ID = int(os.getenv("CHAT_ID", "0")) or None

CHANNEL_ID = os.getenv("CHANNEL_ID") or None

CHANNEL_LINK = os.getenv("CHANNEL_LINK", "https://t.me/")