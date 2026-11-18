from typing import Callable, Awaitable, Any

import aiohttp
from aiogram import BaseMiddleware
from aiogram.fsm.context import FSMContext
from aiogram.types import (
    Message, CallbackQuery, TelegramObject, InlineKeyboardMarkup, InlineKeyboardButton,
)

from config import BOT_TOKEN, CHANNEL_ID, CHANNEL_LINK


class ResetFsmOnCommandMiddleware(BaseMiddleware):
    """Если пользователь в FSM и присылает команду (кроме /cancel, /start, /done, /skip) —
    сбрасываем FSM и пропускаем сообщение дальше."""

    ALLOWED = {"/cancel", "/start", "/done", "/skip"}

    async def __call__(
        self,
        handler: Callable[[TelegramObject, dict[str, Any]], Awaitable[Any]],
        event: TelegramObject,
        data: dict[str, Any],
    ) -> Any:
        if not isinstance(event, Message):
            return await handler(event, data)

        text = (event.text or "").strip()
        if not text.startswith("/"):
            return await handler(event, data)

        cmd = text.split()[0].split("@")[0].lower()
        if cmd in self.ALLOWED:
            return await handler(event, data)

        state: FSMContext | None = data.get("state")
        if state is not None:
            current = await state.get_state()
            if current:
                await state.clear()
                await event.answer(
                    "⚠️ Предыдущее действие отменено (вы прислали команду во время диалога)."
                )

        return await handler(event, data)


class SubscriptionGateMiddleware(BaseMiddleware):
    """Не пропускает пользователя дальше, если он не подписан на канал.
    Админы (role=admin) пропускаются всегда."""

    SKIP_COMMANDS = {"/start", "/help", "/cancel", "/check_sub"}

    def __init__(self):
        self.channel_id = CHANNEL_ID
        self.channel_link = CHANNEL_LINK
        self.bot_token = BOT_TOKEN

    async def _is_subscribed(self, user_id: int) -> bool:
        if not self.channel_id:
            return True  # если канал не настроен — не блокируем
        url = f"https://api.telegram.org/bot{self.bot_token}/getChatMember"
        async with aiohttp.ClientSession() as http:
            async with http.post(
                url, json={"chat_id": self.channel_id, "user_id": user_id}
            ) as resp:
                data = await resp.json()
                if not data.get("ok"):
                    print(f"[subscription] getChatMember error: {data}")
                    return False
                return data["result"]["status"] in ("member", "administrator", "creator")

    def _gate_keyboard(self) -> InlineKeyboardMarkup:
        return InlineKeyboardMarkup(inline_keyboard=[
            [InlineKeyboardButton(text="📢 Подписаться", url=self.channel_link)],
            [InlineKeyboardButton(text="✅ Проверить", callback_data="check_sub")],
        ])

    async def __call__(
        self,
        handler: Callable[[TelegramObject, dict[str, Any]], Awaitable[Any]],
        event: TelegramObject,
        data: dict[str, Any],
    ) -> Any:
        if not isinstance(event, (Message, CallbackQuery)):
            return await handler(event, data)

        user = event.from_user
        if user is None:
            return await handler(event, data)

        # админов пропускаем всегда
        from db.base import SessionLocal
        from db.models import User as UserModel
        async with SessionLocal() as session:
            db_user = await session.get(UserModel, user.id)
            if db_user and db_user.role == "admin":
                return await handler(event, data)

        # команды-исключения
        if isinstance(event, Message) and event.text:
            cmd = event.text.split()[0].split("@")[0].lower()
            if cmd in self.SKIP_COMMANDS:
                return await handler(event, data)

        # callback «Проверить»
        if isinstance(event, CallbackQuery) and event.data == "check_sub":
            return await handler(event, data)

        if await self._is_subscribed(user.id):
            return await handler(event, data)

        text = (
            "🔒 Для использования бота подпишитесь на наш канал.\n\n"
            "После подписки нажмите «✅ Проверить»."
        )
        if isinstance(event, Message):
            await event.answer(text, reply_markup=self._gate_keyboard())
        else:
            await event.answer("🔒 Сначала подпишитесь на канал", show_alert=True)
            await event.message.answer(text, reply_markup=self._gate_keyboard())
        return None

class BanMiddleware(BaseMiddleware):
    """Блокирует все события от забаненных пользователей."""

    async def __call__(
        self,
        handler: Callable[[TelegramObject, dict[str, Any]], Awaitable[Any]],
        event: TelegramObject,
        data: dict[str, Any],
    ) -> Any:
        if not isinstance(event, (Message, CallbackQuery)):
            return await handler(event, data)

        user = event.from_user
        if user is None:
            return await handler(event, data)

        from db.base import SessionLocal
        from db.models import User as UserModel
        async with SessionLocal() as session:
            db_user = await session.get(UserModel, user.id)
            if db_user and db_user.is_banned:
                if isinstance(event, CallbackQuery):
                    await event.answer("🚫 Вы забанены и не можете пользоваться ботом.", show_alert=True)
                else:
                    reason = db_user.ban_reason or "не указана"
                    await event.answer(
                        f"🚫 Вы забанены и не можете пользоваться ботом.\n\n"
                        f"Причина: {reason}"
                    )
                return None

        return await handler(event, data)


class PrivateOnlyCommandsMiddleware(BaseMiddleware):
    """Блокирует команды (текст, начинающийся с /) вне личных сообщений.
    Исключение — /start (может быть в группе) и служебные."""

    ALLOWED_IN_GROUPS = {"/start"}

    async def __call__(
        self,
        handler: Callable[[TelegramObject, dict[str, Any]], Awaitable[Any]],
        event: TelegramObject,
        data: dict[str, Any],
    ) -> Any:
        if not isinstance(event, Message):
            return await handler(event, data)

        if event.chat.type == "private":
            return await handler(event, data)

        text = (event.text or "").strip()
        if not text.startswith("/"):
            return await handler(event, data)  # обычный текст — не команда, пусть идёт в on_chat_message

        cmd = text.split()[0].split("@")[0].lower()
        if cmd in self.ALLOWED_IN_GROUPS:
            return await handler(event, data)

        # в группе команда — игнорируем (не отвечаем, чтобы не спамить)
        return None