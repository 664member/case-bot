from datetime import datetime, timezone, timedelta
import json

from aiogram import Router, F, Bot
from aiogram.filters import Command, CommandObject, StateFilter, CommandStart, ChatMemberUpdatedFilter, IS_NOT_MEMBER, IS_MEMBER
from aiogram.fsm.context import FSMContext
from aiogram.types import (
    Message, CallbackQuery, InlineKeyboardMarkup, InlineKeyboardButton,
    WebAppInfo, ChatMemberUpdated,
)
from sqlalchemy import select, func, update
import uuid
import asyncio
from pathlib import Path

STATIC_IMAGES = Path(__file__).parent.parent / "static" / "images"
STATIC_IMAGES.mkdir(parents=True, exist_ok=True)

from config import CHANNEL_ID, CHANNEL_LINK, CHAT_ID, WEBAPP_URL
from db.base import SessionLocal
from db.models import (
    User, Season, UserSeasonStats, PointTransaction, Case, CaseItem, Drop,
    Tournament, TournamentTemplate, TournamentEntry, ActivityRewardConfig,
)
from bot.states import (
    NewCaseStates, EditCaseStates, EditTourStates, ActivityConfigStates, BroadcastStates,
    ImageUploadStates, RulesStates, WipeBalanceStates,
)
from bot.keyboards import (
    items_keyboard, confirm_keyboard, rarity_keyboard, rarity_keyboard_for_item,
    edit_case_keyboard, item_list_keyboard, item_menu_keyboard, item_delete_confirm_keyboard,
    edit_tour_keyboard, activity_config_keyboard, RARITIES,
)
from services.activity_service import (
    reward_comment, reward_subscription, reward_referral,
    qualifies_for_referral, get_or_create_config,
)

router = Router()

VALID_ROLES = {"user", "moderator", "admin"}


async def get_active_season(session) -> Season | None:
    stmt = select(Season).where(Season.status == "active").order_by(Season.id.desc())
    return (await session.execute(stmt)).scalar_one_or_none()


async def get_role(session, user_id: int) -> str:
    user = await session.get(User, user_id)
    return user.role if user else "user"


def is_admin(role: str) -> bool:
    return role == "admin"


def is_moderator_or_higher(role: str) -> bool:
    return role in ("moderator", "admin")


def active_items_stmt(case_id: int):
    return select(CaseItem).where(
        CaseItem.case_id == case_id,
        CaseItem.deleted_at.is_(None),
    )


# ---------- Кнопки ----------

def _webapp_button() -> InlineKeyboardMarkup:
    from config import WEBAPP_URL
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="🎰 Открыть приложение", web_app=WebAppInfo(url=WEBAPP_URL))],
    ])



def _subscribe_keyboard() -> InlineKeyboardMarkup:
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="📢 Подписаться на канал", url=CHANNEL_LINK)],
        [InlineKeyboardButton(text="✅ Проверить", callback_data="check_sub")],
    ])


# ---------- Отмена ----------

@router.message(Command("cancel"))
async def cmd_cancel(message: Message, state: FSMContext):
    current = await state.get_state()
    await state.clear()
    if current:
        await message.answer("❌ Действие отменено. Вы вернулись в обычный режим.")
    else:
        await message.answer("Нечего отменять.")


# ---------- /start и /help ----------

@router.message(CommandStart(deep_link=True))
async def cmd_start_deeplink(message: Message, command: CommandObject, state: FSMContext):
    await state.clear()
    async with SessionLocal() as session:
        tg_user = message.from_user
        user = await session.get(User, tg_user.id)
        if not user:
            user = User(id=tg_user.id, username=tg_user.username, first_name=tg_user.first_name)
            session.add(user)
            await session.flush()
        else:
            user.username = tg_user.username
            user.first_name = tg_user.first_name

        if command.args and command.args.startswith("ref_"):
            try:
                referrer_id = int(command.args[4:])
            except Exception:
                referrer_id = None
            if referrer_id and referrer_id != tg_user.id and not user.referred_by:
                user.referred_by = referrer_id

        season = await get_active_season(session)
        if season:
            await reward_subscription(session, season.id, tg_user.id)
            if user.referred_by:
                cfg = await get_or_create_config(session, season.id)
                if not cfg.referral_requires_action:
                    await reward_referral(session, season.id, user.referred_by, tg_user.id)
        await session.commit()

    await cmd_help(message)


@router.message(CommandStart())
async def cmd_start(message: Message, state: FSMContext):
    await state.clear()
    async with SessionLocal() as session:
        tg_user = message.from_user
        user = await session.get(User, tg_user.id)
        if not user:
            user = User(id=tg_user.id, username=tg_user.username, first_name=tg_user.first_name)
            session.add(user)
            await session.flush()
        else:
            user.username = tg_user.username
            user.first_name = tg_user.first_name

        season = await get_active_season(session)
        if season:
            await reward_subscription(session, season.id, tg_user.id)
        await session.commit()

    await cmd_help(message)


@router.message(Command("help"))
async def cmd_help(message: Message):
    async with SessionLocal() as session:
        user = await session.get(User, message.from_user.id)
        role = user.role if user else "user"

    from bot.middlewares import SubscriptionGateMiddleware
    mw = SubscriptionGateMiddleware()
    is_admin_user = role == "admin"
    subscribed = is_admin_user or await mw._is_subscribed(message.from_user.id)
    kb = _webapp_button() if subscribed else _subscribe_keyboard()

    if is_moderator_or_higher(role):
        text = (
            "🛠 <b>Команды администратора</b>\n"
            "<i>Нажми на команду — она скопируется в буфер обмена</i>\n\n"
            "<b>Пользователи и роли</b>\n"
            "<code>/whoami</code> — id, роль, сезон, баланс\n"
            "<code>/addpoints ID СУММА</code> — начислить очки (admin)\n"
            "<code>/grant ID РОЛЬ</code> — выдать роль: user | moderator | admin (admin)\n"
            "<code>/revoke ID</code> — снять роль до user (admin)\n"
            "<code>/users</code> — пользователи с ролями выше user (admin)\n"
            "<code>/ban ID_ИЛИ_@USER ПРИЧИНА</code> — забанить и обнулить очки (admin)\n"
            "<code>/unban ID</code> — разбанить (admin)\n"
            "<code>/banned</code> — список забаненных (admin)\n\n"
            "<b>Кейсы</b>\n"
            "<code>/cases</code> — список кейсов\n"
            "<code>/newcase</code> — создать кейс\n"
            "<code>/editcase ID</code> — редактировать кейс (имя, цена, картинка, предметы, статус)\n"
            "<code>/setcaseimage ID</code> — установить картинку кейса\n"
            "<code>/setitemimage ID</code> — установить картинку предмета\n\n"
            "<b>Турниры</b>\n"
            "<code>/newtour ТИП ЧАСЫ TOP MIN \"ИМЯ\" НАГРАДЫ_JSON</code> — создать шаблон\n"
            "   ТИП: daily | weekly | monthly | custom\n"
            "   пример: <code>/newtour daily 24 3 0 \"Дневной блиц\" {\"1\":{\"points\":100},\"2\":{\"points\":50}}</code>\n"
            "<code>/tours</code> — список шаблонов\n"
            "<code>/edittour ID</code> — редактировать шаблон:\n"
            "   top_n, display_limit, награды по местам, повтор,\n"
            "   <b>длина ника</b> и <b>тексты призов</b> (для лидерборда)\n"
            "<code>/currenttour</code> — активные турниры с топом\n"
            "<code>/tourhistory</code> — история турниров сезона\n"
            "<code>/tourt ID</code> — детали турнира\n"
            "<code>/stoptour ID</code> — остановить турнир и отключить его повторения (только admin)\n"
        "<code>/stopalltour</code> — остановить все активные турниры и отключить их повторения (только admin)\n"
            "<code>/deltour ID</code> — деактивировать шаблон (admin)\n"
            "<code>/toggletour ID</code> — вкл/выкл повтор (admin)\n\n"
            "<b>Экономика</b>\n"
            "<code>/rewards</code> — очки за комментарии/подписку/реферал, лимиты, кулдауны\n"
            "<code>/quality</code> — качество дропов (Float): шансы FN/MW/FT/WW/BS, множители стоимости, StatTrak\n"
            "<code>/wipeinventory</code> — очистить инвентарь ВСЕХ пользователей (admin)\n"
            "<code>/wipebalance [значение]</code> — обнулить баланс ВСЕХ пользователей и установить [новый баланс] \n\n"
            "<b>Рефералы</b>\n"
            "<code>/ref</code> — персональная инвайт-ссылка в группу\n\n"
            "<b>Рассылка</b>\n"
            "<code>/rules</code> — редактировать правила и вкл/выкл попап (admin)\n"
            "<code>/broadcast</code> — отправить сообщение всем пользователям (admin)\n\n"
            "💡 <code>/cancel</code> — отменить текущий диалог (FSM)"
        )
        await message.answer(text, parse_mode="HTML", reply_markup=kb)
        return

    text = (
        "👋 <b>Добро пожаловать!</b>\n\n"
        "Это бот с кейсами в стиле CS2. Открывай кейсы, зарабатывай очки и участвуй в турнирах.\n\n"
        "<b>Доступные команды</b>\n"
        "<i>Нажми на команду — она скопируется</i>\n\n"
        "<code>/start</code> — перезапустить бота\n"
        "<code>/whoami</code> — id, роль, сезон и баланс\n"
        "<code>/ref</code> — реферальная ссылка\n"
        "<code>/help</code> — эта справка\n"
        "<code>/cancel</code> — отменить текущий диалог\n\n"
        "🎁 Ежедневный бонус, рулетка, кейсы, инвентарь и турниры — внутри приложения.\n"
        "Нажми кнопку ниже, чтобы открыть его."
    )
    await message.answer(text, parse_mode="HTML", reply_markup=kb)
# ---------- open_app / check_sub ----------


@router.callback_query(F.data == "check_sub")
async def on_check_sub(callback: CallbackQuery):
    from bot.middlewares import SubscriptionGateMiddleware
    mw = SubscriptionGateMiddleware()
    if await mw._is_subscribed(callback.from_user.id):
        await callback.answer("✅ Подписка подтверждена!")
        await callback.bot.send_message(
            chat_id=callback.from_user.id,
            text="✅ Спасибо за подписку! Теперь можете открыть приложение:",
            reply_markup=_webapp_button(),
        )
    else:
        await callback.answer("❌ Вы ещё не подписаны на канал", show_alert=True)

# ---------- /whoami ----------

@router.message(Command("whoami"))
async def cmd_whoami(message: Message):
    async with SessionLocal() as session:
        user = await session.get(User, message.from_user.id)
        role = user.role if user else "user"
        season = await get_active_season(session)
        stats = None
        if season and user:
            stats = (await session.execute(
                select(UserSeasonStats).where(
                    UserSeasonStats.user_id == user.id,
                    UserSeasonStats.season_id == season.id,
                )
            )).scalar_one_or_none()
        balance = stats.points_balance if stats else 0
        await message.answer(
            f"👤 id: <code>{message.from_user.id}</code>\n"
            f"Роль: <b>{role}</b>\n"
            f"Сезон: {season.name if season else '—'}\n"
            f"Баланс: {balance}",
            parse_mode="HTML",
        )


# ---------- /ref ----------

@router.message(Command("ref"))
async def cmd_ref(message: Message):
    async with SessionLocal() as session:
        user = await session.get(User, message.from_user.id)
        if not user:
            await message.answer("Сначала отправьте /start")
            return

    if not CHAT_ID:
        await message.answer("CHAT_ID не настроен в .env")
        return

    try:
        link_obj = await message.bot.create_chat_invite_link(
            chat_id=CHAT_ID,
            name=f"ref_{message.from_user.id}",
        )
        link = link_obj.invite_link
    except Exception as e:
        await message.answer(f"Не удалось создать ссылку: {e}")
        return

    kb = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(
            text="📤 Поделиться ссылкой",
            url=f"https://t.me/share/url?url={link}&text=Залетай%20в%20нашу%20группу!",
        )],
    ])

    await message.answer(
        f"👥 <b>Ваша реферальная ссылка</b>\n\n"
        f"<code>{link}</code>\n\n"
        f"Пригласи друга — получишь очки, когда он зайдёт в группу.",
        parse_mode="HTML",
        reply_markup=kb,
    )


# ---------- /addpoints ----------

@router.message(Command("addpoints"))
async def cmd_addpoints(message: Message, command: CommandObject):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_admin(role):
            await message.answer("⛔ Только для админа")
            return

        if not command.args:
            await message.answer("Использование: /addpoints <user_id|me> <amount>")
            return

        parts = command.args.split()
        if len(parts) != 2:
            await message.answer("Формат: /addpoints <user_id|me> <amount>")
            return

        target_raw, amount_raw = parts
        try:
            amount = int(amount_raw)
        except ValueError:
            await message.answer("Сумма должна быть числом")
            return

        if target_raw.lower() == "me":
            target_id = message.from_user.id
        else:
            try:
                target_id = int(target_raw)
            except ValueError:
                await message.answer("user_id должен быть числом или 'me'")
                return

        season = await get_active_season(session)
        if not season:
            await message.answer("Нет активного сезона")
            return

        user = await session.get(User, target_id)
        if not user:
            user = User(id=target_id, role="user")
            session.add(user)
            await session.flush()

        stats = (await session.execute(
            select(UserSeasonStats).where(
                UserSeasonStats.user_id == target_id,
                UserSeasonStats.season_id == season.id,
            )
        )).scalar_one_or_none()
        if not stats:
            stats = UserSeasonStats(user_id=target_id, season_id=season.id, points_balance=0)
            session.add(stats)
            await session.flush()

        stats.points_balance += amount
        tx = PointTransaction(
            season_id=season.id,
            user_id=target_id,
            amount=amount,
            source="manual",
            meta={"admin_id": message.from_user.id, "reason": "addpoints command"},
        )
        session.add(tx)
        await session.commit()

        await message.answer(
            f"✅ Начислено {amount} очков пользователю <code>{target_id}</code>\n"
            f"Новый баланс: {stats.points_balance}",
            parse_mode="HTML",
        )


# ---------- /grant /revoke /users ----------

@router.message(Command("grant"))
async def cmd_grant(message: Message, command: CommandObject):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_admin(role):
            await message.answer("⛔ Только для админа")
            return

        if not command.args:
            await message.answer("Использование: /grant <user_id> <role>")
            return

        parts = command.args.split()
        if len(parts) != 2:
            await message.answer("Формат: /grant <user_id> <role>")
            return

        target_raw, new_role = parts
        if new_role not in VALID_ROLES:
            await message.answer(f"Недопустимая роль. Допустимо: {', '.join(sorted(VALID_ROLES))}")
            return

        try:
            target_id = int(target_raw)
        except ValueError:
            await message.answer("user_id должен быть числом")
            return

        user = await session.get(User, target_id)
        if not user:
            user = User(id=target_id, role=new_role)
            session.add(user)
        else:
            user.role = new_role
        await session.commit()

        await message.answer(
            f"✅ Пользователю <code>{target_id}</code> выдана роль <b>{new_role}</b>",
            parse_mode="HTML",
        )


@router.message(Command("revoke"))
async def cmd_revoke(message: Message, command: CommandObject):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_admin(role):
            await message.answer("⛔ Только для админа")
            return

        if not command.args:
            await message.answer("Использование: /revoke <user_id>")
            return

        try:
            target_id = int(command.args.strip())
        except ValueError:
            await message.answer("user_id должен быть числом")
            return

        if target_id == message.from_user.id:
            await message.answer("⚠️ Нельзя снять роль с самого себя")
            return

        user = await session.get(User, target_id)
        if not user:
            await message.answer("Пользователь не найден")
            return

        user.role = "user"
        await session.commit()

        await message.answer(
            f"✅ С пользователя <code>{target_id}</code> снята роль (теперь user)",
            parse_mode="HTML",
        )


@router.message(Command("users"))
async def cmd_users(message: Message):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_admin(role):
            await message.answer("⛔ Только для админа")
            return

        users = (await session.execute(
            select(User).where(User.role != "user").order_by(User.id)
        )).scalars().all()

        if not users:
            await message.answer("Пользователей с ролями выше user нет")
            return

        lines = ["👥 Пользователи с ролями:"]
        for u in users:
            uname = f"@{u.username}" if u.username else "—"
            lines.append(f"<code>{u.id}</code> — {uname} — <b>{u.role}</b>")
        await message.answer("\n".join(lines), parse_mode="HTML")


# ---------- /cases ----------

@router.message(Command("cases"))
async def cmd_cases(message: Message):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_moderator_or_higher(role):
            await message.answer("⛔ Только для модераторов и админов")
            return

        season = await get_active_season(session)
        if not season:
            await message.answer("Нет активного сезона")
            return

        cases = (await session.execute(
            select(Case).where(Case.season_id == season.id).order_by(Case.id)
        )).scalars().all()

        if not cases:
            await message.answer("Кейсов пока нет")
            return

        lines = [f"📦 Кейсы сезона «{season.name}»:"]
        for c in cases:
            items = (await session.execute(active_items_stmt(c.id))).scalars().all()
            status = "✅" if c.is_active else "⏸"
            lines.append(
                f"{status} <code>{c.id}</code> — <b>{c.name}</b> — {c.price_points} очков — {len(items)} предметов"
            )
        await message.answer("\n".join(lines), parse_mode="HTML")


# ---------- Создание кейса ----------

@router.message(Command("newcase"))
async def cmd_newcase(message: Message, state: FSMContext):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_moderator_or_higher(role):
            await message.answer("⛔ Только для модераторов и админов")
            return

    await state.clear()
    await state.update_data(items=[])
    await state.set_state(NewCaseStates.name)
    await message.answer("📦 Создание кейса\n\nШаг 1/4: введите название кейса (до 64 символов).\n\n/cancel — отмена")


@router.message(NewCaseStates.name)
async def newcase_name(message: Message, state: FSMContext):
    if message.text == "/cancel":
        await state.clear()
        await message.answer("❌ Отменено")
        return
    name = (message.text or "").strip()
    if not name or len(name) > 64:
        await message.answer("Название должно быть от 1 до 64 символов")
        return
    await state.update_data(name=name)
    await state.set_state(NewCaseStates.price)
    await message.answer("Шаг 2/4: введите цену открытия в очках (целое число > 0)\n\n/cancel — отмена")


@router.message(NewCaseStates.price)
async def newcase_price(message: Message, state: FSMContext):
    if message.text == "/cancel":
        await state.clear()
        await message.answer("❌ Отменено")
        return
    try:
        price = int((message.text or "").strip())
        if price <= 0:
            raise ValueError
    except ValueError:
        await message.answer("Цена должна быть целым числом > 0")
        return
    await state.update_data(price=price)
    await state.set_state(NewCaseStates.items)
    await message.answer(
        "Шаг 3/4: добавьте предметы.\n\n"
        "Нажмите «Добавить предмет» и следуйте подсказкам. Минимум 1 предмет.\n"
        "Когда закончите — «Завершить создание».",
        reply_markup=items_keyboard(),
    )


@router.callback_query(F.data == "newcase:add_item")
async def newcase_add_item(callback: CallbackQuery, state: FSMContext):
    await callback.answer()
    await state.update_data(adding_item={}, step="item_name")
    await callback.message.answer("Введите название предмета (до 64 символов):\n\n/cancel — отмена")


@router.message(NewCaseStates.items)
async def newcase_items_text(message: Message, state: FSMContext):
    data = await state.get_data()
    step = data.get("step")

    if message.text == "/cancel":
        await state.clear()
        await message.answer("❌ Отменено")
        return

    if step == "item_name":
        name = (message.text or "").strip()
        if not name or len(name) > 64:
            await message.answer("Название от 1 до 64 символов")
            return
        adding = data.get("adding_item", {})
        adding["name"] = name
        await state.update_data(adding_item=adding, step="item_rarity")
        await message.answer("Выберите редкость:", reply_markup=rarity_keyboard())
        return

    if step == "item_weight":
        try:
            weight = int((message.text or "").strip())
            if weight <= 0:
                raise ValueError
        except ValueError:
            await message.answer("Вес — целое число > 0")
            return
        adding = data.get("adding_item", {})
        adding["weight"] = weight
        adding["quality_score"] = 1
        await state.update_data(adding_item=adding, step="item_point_value")  # сразу к point_value
        await message.answer("Введите награду (очки, целое число ≥ 0):\n\n/cancel — отмена")
        return

    if step == "item_point_value":
        try:
            pv = int((message.text or "").strip())
            if pv < 0:
                raise ValueError
        except ValueError:
            await message.answer("Награда — целое число ≥ 0")
            return
        adding = data.get("adding_item", {})
        adding["point_value"] = pv
        await state.update_data(adding_item=adding, step=None)
        await state.set_state(NewCaseStates.add_item_image)
        await message.answer(
            "Отправьте картинку для предмета (фото, файл или стикер)\n"
            "или пропустите — тогда будет заглушка.",
            reply_markup=InlineKeyboardMarkup(inline_keyboard=[
                [InlineKeyboardButton(text="⏭ Пропустить", callback_data="newcase:skip_image")],
                [InlineKeyboardButton(text="❌ Отмена", callback_data="newcase:cancel")],
            ]),
        )
        return

    await message.answer("Используйте кнопки ниже", reply_markup=items_keyboard())


@router.callback_query(F.data.startswith("rarity:"), StateFilter(NewCaseStates.items))
async def newcase_rarity(callback: CallbackQuery, state: FSMContext):
    rarity = callback.data.split(":", 1)[1]
    if rarity not in RARITIES:
        await callback.answer("Неизвестная редкость", show_alert=True)
        return
    data = await state.get_data()
    adding = data.get("adding_item", {})
    adding["rarity"] = rarity
    await state.update_data(adding_item=adding, step="item_weight")
    await callback.answer()
    await callback.message.answer(f"Редкость: {rarity}\n\nВведите вес (целое число > 0):\n\n/cancel — отмена")


@router.callback_query(F.data == "newcase:finish")
async def newcase_finish(callback: CallbackQuery, state: FSMContext):
    data = await state.get_data()
    items = data.get("items", [])
    if not items:
        await callback.answer("Добавьте хотя бы один предмет", show_alert=True)
        return
    name = data.get("name", "?")
    price = data.get("price", 0)
    total_weight = sum(i["weight"] for i in items)
    lines = [f"📦 <b>{name}</b> — {price} очков", "", "Предметы:"]
    for i in items:
        chance = i["weight"] / total_weight * 100
        lines.append(f"• {i['name']} ({i['rarity']}) — {chance:.1f}% — награда {i['point_value']}")
    lines.append("\nСоздать кейс?")
    await state.set_state(NewCaseStates.confirm)
    await callback.answer()
    await callback.message.answer("\n".join(lines), parse_mode="HTML", reply_markup=confirm_keyboard())


@router.callback_query(F.data == "newcase:confirm")
async def newcase_confirm(callback: CallbackQuery, state: FSMContext):
    data = await state.get_data()
    items = data.get("items", [])
    name = data.get("name")
    price = data.get("price")

    async with SessionLocal() as session:
        season = await get_active_season(session)
        if not season:
            await callback.answer("Нет активного сезона", show_alert=True)
            await state.clear()
            return

        case = Case(
            season_id=season.id,
            name=name,
            price_points=price,
            is_active=True,
            created_by=callback.from_user.id,
        )
        session.add(case)
        await session.flush()

        for i in items:
            session.add(CaseItem(
                case_id=case.id,
                name=i["name"],
                rarity=i["rarity"],
                weight=i["weight"],
                quality_score=i.get("quality_score", 1),
                point_value=i["point_value"],
                image_url=i.get("image_url"),
            ))
        await session.commit()

        await callback.answer("Кейс создан")
        await callback.message.answer(f"✅ Кейс <b>{name}</b> создан (id: {case.id})", parse_mode="HTML")
    await state.clear()


@router.callback_query(F.data == "newcase:cancel")
async def newcase_cancel(callback: CallbackQuery, state: FSMContext):
    await state.clear()
    await callback.answer("Отменено")
    await callback.message.answer("❌ Создание кейса отменено")


# ---------- Редактирование кейса ----------

@router.message(Command("editcase"))
async def cmd_editcase(message: Message, command: CommandObject, state: FSMContext):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_moderator_or_higher(role):
            await message.answer("⛔ Только для модераторов и админов")
            return

    if not command.args:
        await message.answer("Использование: /editcase <case_id>")
        return

    try:
        case_id = int(command.args.strip())
    except ValueError:
        await message.answer("case_id должен быть числом")
        return

    async with SessionLocal() as session:
        case = await session.get(Case, case_id)
        if not case:
            await message.answer("Кейс не найден")
            return
        await message.answer(
            f"✏️ Редактирование кейса <b>{case.name}</b> (id: {case.id})\n"
            f"Цена: {case.price_points}, активен: {case.is_active}",
            parse_mode="HTML",
            reply_markup=edit_case_keyboard(case.id, case.is_active),
        )


@router.callback_query(F.data == "editcase:back")
async def editcase_back(callback: CallbackQuery):
    await callback.answer()
    await callback.message.answer("Используйте /editcase <id> для выбора кейса")


@router.callback_query(F.data.startswith("editcase:name:"))
async def editcase_name(callback: CallbackQuery, state: FSMContext):
    case_id = int(callback.data.split(":")[2])
    await state.set_state(EditCaseStates.edit_name)
    await state.update_data(edit_case_id=case_id)
    await callback.answer()
    await callback.message.answer("Введите новое имя кейса:\n\n/cancel — отмена")


@router.message(EditCaseStates.edit_name)
async def editcase_name_save(message: Message, state: FSMContext):
    data = await state.get_data()
    case_id = data["edit_case_id"]
    name = (message.text or "").strip()
    if not name or len(name) > 64:
        await message.answer("Имя от 1 до 64 символов")
        return
    async with SessionLocal() as session:
        case = await session.get(Case, case_id)
        if not case:
            await message.answer("Кейс не найден")
            await state.clear()
            return
        case.name = name
        await session.commit()
        await message.answer(f"✅ Имя изменено на «{name}»")
    await state.clear()


@router.callback_query(F.data.startswith("editcase:price:"))
async def editcase_price(callback: CallbackQuery, state: FSMContext):
    case_id = int(callback.data.split(":")[2])
    await state.set_state(EditCaseStates.edit_price)
    await state.update_data(edit_case_id=case_id)
    await callback.answer()
    await callback.message.answer("Введите новую цену (целое число > 0):\n\n/cancel — отмена")


@router.message(EditCaseStates.edit_price)
async def editcase_price_save(message: Message, state: FSMContext):
    data = await state.get_data()
    case_id = data["edit_case_id"]
    try:
        price = int((message.text or "").strip())
        if price <= 0:
            raise ValueError
    except ValueError:
        await message.answer("Цена — целое число > 0")
        return
    async with SessionLocal() as session:
        case = await session.get(Case, case_id)
        if not case:
            await message.answer("Кейс не найден")
            await state.clear()
            return
        case.price_points = price
        await session.commit()
        await message.answer(f"✅ Цена изменена на {price}")
    await state.clear()


@router.callback_query(F.data.startswith("editcase:toggle:"))
async def editcase_toggle(callback: CallbackQuery):
    case_id = int(callback.data.split(":")[2])
    async with SessionLocal() as session:
        case = await session.get(Case, case_id)
        if not case:
            await callback.answer("Кейс не найден", show_alert=True)
            return
        case.is_active = not case.is_active
        await session.commit()
        await callback.answer("Статус изменён")
        await callback.message.edit_text(
            f"✏️ Редактирование кейса <b>{case.name}</b> (id: {case.id})\n"
            f"Цена: {case.price_points}, активен: {case.is_active}",
            parse_mode="HTML",
            reply_markup=edit_case_keyboard(case.id, case.is_active),
        )


@router.callback_query(F.data.startswith("editcase:showitems:"))
async def editcase_showitems(callback: CallbackQuery):
    case_id = int(callback.data.split(":")[2])
    async with SessionLocal() as session:
        items = (await session.execute(
            active_items_stmt(case_id).order_by(CaseItem.id)
        )).scalars().all()
        if not items:
            await callback.answer()
            await callback.message.answer("В кейсе нет предметов")
            return
        await callback.answer()
        await callback.message.answer(
            f"📋 Предметы кейса {case_id}. Нажмите на предмет для редактирования:",
            reply_markup=item_list_keyboard(case_id, items),
        )


@router.callback_query(F.data.startswith("editcase:back_to:"))
async def editcase_back_to(callback: CallbackQuery):
    case_id = int(callback.data.split(":")[2])
    async with SessionLocal() as session:
        case = await session.get(Case, case_id)
        if not case:
            await callback.answer("Кейс не найден", show_alert=True)
            return
        await callback.answer()
        await callback.message.edit_text(
            f"✏️ Редактирование кейса <b>{case.name}</b> (id: {case.id})\n"
            f"Цена: {case.price_points}, активен: {case.is_active}",
            parse_mode="HTML",
            reply_markup=edit_case_keyboard(case.id, case.is_active),
        )


@router.callback_query(F.data.startswith("editcase:additem:"))
async def editcase_additem(callback: CallbackQuery, state: FSMContext):
    case_id = int(callback.data.split(":")[2])
    await state.update_data(edit_case_id=case_id, edit_adding_item={})
    await state.set_state(EditCaseStates.add_item_name)
    await callback.answer()
    await callback.message.answer("Введите название нового предмета:\n\n/cancel — отмена")


@router.message(EditCaseStates.add_item_name)
async def editcase_additem_name(message: Message, state: FSMContext):
    name = (message.text or "").strip()
    if not name or len(name) > 64:
        await message.answer("Название от 1 до 64 символов")
        return
    data = await state.get_data()
    adding = data.get("edit_adding_item", {})
    adding["name"] = name
    await state.update_data(edit_adding_item=adding)
    await state.set_state(EditCaseStates.add_item_rarity)
    await message.answer("Выберите редкость:", reply_markup=rarity_keyboard())


@router.callback_query(F.data.startswith("rarity:"), StateFilter(EditCaseStates.add_item_rarity))
async def editcase_additem_rarity(callback: CallbackQuery, state: FSMContext):
    rarity = callback.data.split(":", 1)[1]
    if rarity not in RARITIES:
        await callback.answer("Неизвестная редкость", show_alert=True)
        return
    data = await state.get_data()
    adding = data.get("edit_adding_item", {})
    adding["rarity"] = rarity
    await state.update_data(edit_adding_item=adding)
    await state.set_state(EditCaseStates.add_item_weight)
    await callback.answer()
    await callback.message.answer("Введите вес (целое число > 0):\n\n/cancel — отмена")


@router.message(EditCaseStates.add_item_weight)
async def editcase_additem_weight(message: Message, state: FSMContext):
    try:
        weight = int((message.text or "").strip())
        if weight <= 0:
            raise ValueError
    except ValueError:
        await message.answer("Вес — целое число > 0")
        return
    data = await state.get_data()
    adding = data.get("edit_adding_item", {})
    adding["weight"] = weight
    adding["quality_score"] = 1
    await state.update_data(edit_adding_item=adding)
    await state.set_state(EditCaseStates.add_item_point_value)
    await message.answer("Введите награду (очки, целое число ≥ 0):\n\n/cancel — отмена")

@router.message(EditCaseStates.add_item_point_value)
async def editcase_additem_point_value(message: Message, state: FSMContext):
    try:
        pv = int((message.text or "").strip())
        if pv < 0:
            raise ValueError
    except ValueError:
        await message.answer("Награда — целое число ≥ 0")
        return
    data = await state.get_data()
    adding = data.get("edit_adding_item", {})
    adding["point_value"] = pv
    await state.update_data(edit_adding_item=adding)
    await state.set_state(EditCaseStates.add_item_image)
    await message.answer(
        "Отправьте картинку для предмета (фото, файл или стикер)\n"
        "или пропустите.",
        reply_markup=InlineKeyboardMarkup(inline_keyboard=[
            [InlineKeyboardButton(text="⏭ Пропустить", callback_data="editcase:skip_item_image")],
            [InlineKeyboardButton(text="❌ Отмена", callback_data="newcase:cancel")],
        ]),
    )


# ---------- Редактирование предмета ----------

@router.callback_query(F.data.startswith("itemedit:menu:"))
async def itemedit_menu(callback: CallbackQuery):
    _, _, case_id_s, item_id_s = callback.data.split(":")
    case_id = int(case_id_s)
    item_id = int(item_id_s)

    async with SessionLocal() as session:
        item = await session.get(CaseItem, item_id)
        if not item or item.case_id != case_id or item.deleted_at is not None:
            await callback.answer("Предмет не найден", show_alert=True)
            return
        items = (await session.execute(active_items_stmt(case_id))).scalars().all()
        total = sum(i.weight for i in items) or 1
        chance = item.weight / total * 100
        await callback.answer()
        await callback.message.edit_text(
            f"🔧 <b>{item.name}</b> (id {item.id})\n"
            f"Редкость: {item.rarity}\n"
            f"Вес: {item.weight} (шанс {chance:.1f}%)\n"
            f"Награда: {item.point_value} очков",
            parse_mode="HTML",
            reply_markup=item_menu_keyboard(case_id, item_id),
        )


@router.callback_query(F.data.startswith("itemedit:name:"))
async def itemedit_name(callback: CallbackQuery, state: FSMContext):
    _, _, case_id_s, item_id_s = callback.data.split(":")
    await state.update_data(item_edit_case_id=int(case_id_s), item_edit_item_id=int(item_id_s))
    await state.set_state(EditCaseStates.item_edit_name)
    await callback.answer()
    await callback.message.answer("Введите новое имя предмета:\n\n/cancel — отмена")


@router.message(EditCaseStates.item_edit_name)
async def itemedit_name_save(message: Message, state: FSMContext):
    data = await state.get_data()
    case_id = data["item_edit_case_id"]
    item_id = data["item_edit_item_id"]
    name = (message.text or "").strip()
    if not name or len(name) > 64:
        await message.answer("Имя от 1 до 64 символов")
        return
    async with SessionLocal() as session:
        item = await session.get(CaseItem, item_id)
        if not item or item.case_id != case_id or item.deleted_at is not None:
            await message.answer("Предмет не найден")
            await state.clear()
            return
        item.name = name
        await session.commit()
        await message.answer(f"✅ Имя предмета изменено на «{name}»")
    await state.clear()


@router.callback_query(F.data.startswith("itemedit:rarity_menu:"))
async def itemedit_rarity_menu(callback: CallbackQuery):
    _, _, case_id_s, item_id_s = callback.data.split(":")
    await callback.answer()
    await callback.message.answer(
        "Выберите новую редкость:",
        reply_markup=rarity_keyboard_for_item(int(case_id_s), int(item_id_s)),
    )


@router.callback_query(F.data.startswith("itemedit:rarity:"))
async def itemedit_rarity_set(callback: CallbackQuery):
    parts = callback.data.split(":")
    if len(parts) != 5:
        await callback.answer("Некорректный callback", show_alert=True)
        return
    _, _, case_id_s, item_id_s, rarity = parts
    case_id = int(case_id_s)
    item_id = int(item_id_s)
    if rarity not in RARITIES:
        await callback.answer("Неизвестная редкость", show_alert=True)
        return
    async with SessionLocal() as session:
        item = await session.get(CaseItem, item_id)
        if not item or item.case_id != case_id or item.deleted_at is not None:
            await callback.answer("Предмет не найден", show_alert=True)
            return
        item.rarity = rarity
        await session.commit()
        await callback.answer("Редкость изменена")
        await callback.message.answer(f"✅ Редкость предмета «{item.name}» теперь {rarity}")


@router.callback_query(F.data.startswith("itemedit:weight:"))
async def itemedit_weight(callback: CallbackQuery, state: FSMContext):
    _, _, case_id_s, item_id_s = callback.data.split(":")
    await state.update_data(item_edit_case_id=int(case_id_s), item_edit_item_id=int(item_id_s))
    await state.set_state(EditCaseStates.item_edit_weight)
    await callback.answer()
    await callback.message.answer("Введите новый вес (целое число > 0):\n\n/cancel — отмена")


@router.message(EditCaseStates.item_edit_weight)
async def itemedit_weight_save(message: Message, state: FSMContext):
    data = await state.get_data()
    case_id = data["item_edit_case_id"]
    item_id = data["item_edit_item_id"]
    try:
        weight = int((message.text or "").strip())
        if weight <= 0:
            raise ValueError
    except ValueError:
        await message.answer("Вес — целое число > 0")
        return
    async with SessionLocal() as session:
        item = await session.get(CaseItem, item_id)
        if not item or item.case_id != case_id or item.deleted_at is not None:
            await message.answer("Предмет не найден")
            await state.clear()
            return
        item.weight = weight
        await session.commit()
        await message.answer(f"✅ Вес изменён на {weight}")
    await state.clear()


@router.callback_query(F.data.startswith("itemedit:point_value:"))
async def itemedit_point_value(callback: CallbackQuery, state: FSMContext):
    _, _, case_id_s, item_id_s = callback.data.split(":")
    await state.update_data(item_edit_case_id=int(case_id_s), item_edit_item_id=int(item_id_s))
    await state.set_state(EditCaseStates.item_edit_point_value)
    await callback.answer()
    await callback.message.answer("Введите новую награду в очках (целое число ≥ 0):\n\n/cancel — отмена")


@router.message(EditCaseStates.item_edit_point_value)
async def itemedit_point_value_save(message: Message, state: FSMContext):
    data = await state.get_data()
    case_id = data["item_edit_case_id"]
    item_id = data["item_edit_item_id"]
    try:
        pv = int((message.text or "").strip())
        if pv < 0:
            raise ValueError
    except ValueError:
        await message.answer("Награда — целое число ≥ 0")
        return
    async with SessionLocal() as session:
        item = await session.get(CaseItem, item_id)
        if not item or item.case_id != case_id or item.deleted_at is not None:
            await message.answer("Предмет не найден")
            await state.clear()
            return
        item.point_value = pv
        await session.commit()
        await message.answer(f"✅ Награда изменена на {pv}")
    await state.clear()


@router.callback_query(F.data.startswith("itemedit:delete_confirm:"))
async def itemedit_delete_confirm(callback: CallbackQuery):
    _, _, case_id_s, item_id_s = callback.data.split(":")
    case_id = int(case_id_s)
    item_id = int(item_id_s)
    async with SessionLocal() as session:
        item = await session.get(CaseItem, item_id)
        if not item or item.case_id != case_id or item.deleted_at is not None:
            await callback.answer("Предмет не найден", show_alert=True)
            return
        items_count = (await session.execute(
            select(func.count(CaseItem.id)).where(
                CaseItem.case_id == case_id,
                CaseItem.deleted_at.is_(None),
            )
        )).scalar_one()
        if items_count <= 1:
            await callback.answer("Нельзя удалить последний предмет в кейсе", show_alert=True)
            return
        drops_count = (await session.execute(
            select(func.count(Drop.id)).where(Drop.item_id == item_id)
        )).scalar_one()
        await callback.answer()
        warn = f"\n\n⚠️ Этот предмет уже выпадал {drops_count} раз(а) — дропы останутся в истории." if drops_count else ""
        await callback.message.answer(
            f"Удалить предмет «{item.name}»?{warn}",
            reply_markup=item_delete_confirm_keyboard(case_id, item_id),
        )


@router.callback_query(F.data.startswith("itemedit:delete_yes:"))
async def itemedit_delete_yes(callback: CallbackQuery):
    _, _, case_id_s, item_id_s = callback.data.split(":")
    case_id = int(case_id_s)
    item_id = int(item_id_s)
    async with SessionLocal() as session:
        item = await session.get(CaseItem, item_id)
        if not item or item.case_id != case_id or item.deleted_at is not None:
            await callback.answer("Предмет не найден", show_alert=True)
            return
        active_count = (await session.execute(
            select(func.count(CaseItem.id)).where(
                CaseItem.case_id == case_id,
                CaseItem.deleted_at.is_(None),
            )
        )).scalar_one()
        if active_count <= 1:
            await callback.answer("Нельзя удалить последний предмет в кейсе", show_alert=True)
            return
        item.deleted_at = datetime.now(timezone.utc)
        await session.commit()
        await callback.answer("Удалено")
        await callback.message.answer(f"🗑 Предмет «{item.name}» удалён из кейса")


# ---------- Турниры ----------

def _parse_reward_config(raw: str) -> dict | None:
    try:
        data = json.loads(raw)
    except Exception:
        return None
    if not isinstance(data, dict):
        return None
    return data


def _next_start_from_type(ttype: str, after: datetime) -> datetime | None:
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


@router.message(Command("tours"))
async def cmd_tours(message: Message):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_moderator_or_higher(role):
            await message.answer("⛔ Только для модераторов и админов")
            return
        season = await get_active_season(session)
        if not season:
            await message.answer("Нет активного сезона")
            return
        templates = (await session.execute(
            select(TournamentTemplate).where(TournamentTemplate.season_id == season.id)
        )).scalars().all()
        if not templates:
            await message.answer("Шаблонов турниров нет. Создайте через /newtour")
            return
        lines = ["🏆 Шаблоны турниров:"]
        for t in templates:
            nxt = t.next_start_at.strftime("%d.%m %H:%M") if t.next_start_at else "—"
            status = "✅" if t.is_active else "⏸"
            lines.append(
                f"{status} <code>{t.id}</code> — <b>{t.name}</b> ({t.type}) — top {t.top_n}, длит. {t.duration_hours}ч, старт: {nxt}"
            )
        await message.answer("\n".join(lines), parse_mode="HTML")


@router.message(Command("newtour"))
async def cmd_newtour(message: Message, command: CommandObject):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_moderator_or_higher(role):
            await message.answer("⛔ Только для модераторов и админов")
            return
        if not command.args:
            await message.answer(
                "Формат:\n/newtour <type> <duration_hours> <top_n> <min_score> <name> <rewards_json>\n\n"
                "type: daily | weekly | monthly | custom\n"
                "rewards_json: {\"1\":{\"points\":100},\"2\":{\"manual\":\"Скин\"}}"
            )
            return
        parts = command.args.split(" ", 4)
        if len(parts) < 5:
            await message.answer("Недостаточно аргументов")
            return
        ttype, dur_s, top_s, min_s, rest = parts
        if ttype not in ("daily", "weekly", "monthly", "custom"):
            await message.answer("type должен быть daily/weekly/monthly/custom")
            return
        try:
            duration = int(dur_s)
            top_n = int(top_s)
            min_score = int(min_s)
            if duration <= 0 or top_n <= 0:
                raise ValueError
        except ValueError:
            await message.answer("duration_hours, top_n, min_score — числа > 0")
            return
        if not rest.startswith('"'):
            await message.answer("Имя в кавычках")
            return
        end_quote = rest.find('"', 1)
        if end_quote == -1:
            await message.answer("Не закрыта кавычка в имени")
            return
        name = rest[1:end_quote]
        rewards_raw = rest[end_quote + 1:].strip()
        rewards = _parse_reward_config(rewards_raw) if rewards_raw else {}
        if rewards is None:
            await message.answer("rewards_json — некорректный JSON")
            return
        season = await get_active_season(session)
        if not season:
            await message.answer("Нет активного сезона")
            return
        now = datetime.now(timezone.utc)
        next_start = _next_start_from_type(ttype, now)
        tpl = TournamentTemplate(
            season_id=season.id,
            name=name,
            type=ttype,
            duration_hours=duration,
            top_n=top_n,
            min_score=min_score,
            score_multiplier={"Common": 1, "Rare": 5, "Epic": 20, "Legendary": 100},
            reward_config=rewards,
            is_active=True,
            is_recurring=(ttype != "custom"),
            next_start_at=next_start,
        )
        session.add(tpl)
        await session.commit()
        nxt_str = next_start.strftime("%d.%m.%Y %H:%M UTC") if next_start else "—"
        await message.answer(
            f"✅ Шаблон турнира создан (id {tpl.id})\nТип: {ttype}, длительность: {duration}ч, top {top_n}, min_score {min_score}\nСтарт: {nxt_str}",
            parse_mode="HTML",
        )


@router.message(Command("currenttour"))
async def cmd_currenttour(message: Message):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_moderator_or_higher(role):
            await message.answer("⛔ Только для модераторов и админов")
            return
        season = await get_active_season(session)
        if not season:
            await message.answer("Нет активного сезона")
            return
        tournaments = (await session.execute(
            select(Tournament).where(
                Tournament.season_id == season.id,
                Tournament.status == "active",
            ).order_by(Tournament.id)
        )).scalars().all()
        if not tournaments:
            await message.answer("Сейчас нет активных турниров")
            return
        for t in tournaments:
            entries = (await session.execute(
                select(TournamentEntry, User)
                .join(User, User.id == TournamentEntry.user_id)
                .where(TournamentEntry.tournament_id == t.id)
                .order_by(TournamentEntry.total_score.desc())
                .limit(t.display_limit or 5)
            )).all()
            lines = [
                f"🏆 <b>{t.name}</b> (id {t.id})",
                f"До: {t.ends_at.strftime('%d.%m %H:%M UTC')}",
                f"top {t.top_n}, min_score {t.min_score}",
                "",
            ]
            if not entries:
                lines.append("Пока никто не набрал очков")
            else:
                for i, (e, u) in enumerate(entries, 1):
                    uname = f"@{u.username}" if u.username else f"id{u.id}"
                    lines.append(f"{i}. {uname} — {e.total_score}")
            await message.answer("\n".join(lines), parse_mode="HTML")


@router.message(Command("tourhistory"))
async def cmd_tourhistory(message: Message):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_moderator_or_higher(role):
            await message.answer("⛔ Только для модераторов и админов")
            return
        season = await get_active_season(session)
        if not season:
            await message.answer("Нет активного сезона")
            return
        tournaments = (await session.execute(
            select(Tournament).where(Tournament.season_id == season.id).order_by(Tournament.id.desc())
        )).scalars().all()
        if not tournaments:
            await message.answer("Турниров ещё не было")
            return
        lines = ["📜 История турниров:"]
        for t in tournaments:
            status_emoji = {"active": "🟢", "finished": "⚪", "scheduled": "🕒"}.get(t.status, "❔")
            ends = t.ends_at.strftime("%d.%m %H:%M") if t.ends_at else "—"
            lines.append(f"{status_emoji} <code>{t.id}</code> — <b>{t.name}</b> [{t.status}] до {ends}")
        lines.append("\nПодробнее: /tourt ID")
        await message.answer("\n".join(lines), parse_mode="HTML")


@router.message(Command("tourt"))
async def cmd_tourt(message: Message, command: CommandObject):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_moderator_or_higher(role):
            await message.answer("⛔ Только для модераторов и админов")
            return
        if not command.args:
            await message.answer("Использование: /tourt <tournament_id>")
            return
        try:
            tid = int(command.args.strip())
        except ValueError:
            await message.answer("tournament_id должен быть числом")
            return
        t = await session.get(Tournament, tid)
        if not t:
            await message.answer("Турнир не найден")
            return
        entries = (await session.execute(
            select(TournamentEntry, User)
            .join(User, User.id == TournamentEntry.user_id)
            .where(TournamentEntry.tournament_id == t.id)
            .order_by(TournamentEntry.total_score.desc())
            .limit(t.display_limit or 30)
        )).all()
        lines = [
            f"🏆 <b>{t.name}</b> (id {t.id})",
            f"Статус: {t.status}",
            f"Период: {t.starts_at.strftime('%d.%m %H:%M')} — {t.ends_at.strftime('%d.%m %H:%M')} UTC",
            f"top {t.top_n}, min_score {t.min_score}",
            "",
        ]
        if not entries:
            lines.append("Участников нет")
        else:
            for i, (e, u) in enumerate(entries, 1):
                uname = f"@{u.username}" if u.username else f"id{u.id}"
                rank_str = f"{e.rank}." if e.rank else f"{i}."
                lines.append(f"{rank_str} {uname} — {e.total_score}")
        await message.answer("\n".join(lines), parse_mode="HTML")


@router.message(Command("stoptour"))
async def cmd_stoptour(message: Message, command: CommandObject):
    """Остановить конкретный турнир и отключить повторения его шаблона.
    /stoptour <tournament_id>"""
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_admin(role):
            await message.answer("⛔ Только для админа")
            return
        season = await get_active_season(session)
        if not season:
            await message.answer("Нет активного сезона")
            return

        if not command.args:
            await message.answer(
                "Использование:\n"
                "<code>/stoptour ID</code> — остановить конкретный турнир и отключить его повторения\n"
                "<code>/stopalltour</code> — остановить все активные турниры и отключить их повторения",
                parse_mode="HTML",
            )
            return

        try:
            tid = int(command.args.strip())
        except ValueError:
            await message.answer("tournament_id должен быть числом")
            return

        t = await session.get(Tournament, tid)
        if not t or t.season_id != season.id or t.status != "active":
            await message.answer("Активный турнир с таким id не найден")
            return

        now = datetime.now(timezone.utc)
        t.ends_at = now

        # Отключаем повторения у шаблона этого турнира
        template_disabled = False
        if t.template_id:
            tpl = await session.get(TournamentTemplate, t.template_id)
            if tpl and tpl.is_recurring:
                tpl.is_recurring = False
                tpl.next_start_at = None
                template_disabled = True

        await session.commit()

        extra = ""
        if template_disabled:
            extra = (
                "\n\n🔁 <b>Повторения этого шаблона отключены</b> — новые копии создаваться не будут.\n"
                "Другие шаблоны не тронуты.\n"
                "Вернуть повтор: <code>/toggletour " + str(t.template_id) + "</code>"
            )

        await message.answer(
            f"⏹ Турнир «{t.name}» (id {t.id}) будет финализирован в течение минуты.{extra}",
            parse_mode="HTML",
        )


@router.message(Command("stopalltour"))
async def cmd_stopalltour(message: Message):
    """Остановить все активные турниры И отключить все запланированные повторения."""
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_admin(role):
            await message.answer("⛔ Только для админа")
            return
        season = await get_active_season(session)
        if not season:
            await message.answer("Нет активного сезона")
            return

        now = datetime.now(timezone.utc)

        # 1) Останавливаем все активные турниры
        active = (await session.execute(
            select(Tournament).where(
                Tournament.season_id == season.id,
                Tournament.status == "active",
            )
        )).scalars().all()
        for t in active:
            t.ends_at = now

        # 2) Отключаем повторения у ВСЕХ шаблонов, у которых есть pending next_start_at
        templates = (await session.execute(
            select(TournamentTemplate).where(
                TournamentTemplate.season_id == season.id,
                TournamentTemplate.next_start_at.is_not(None),
            )
        )).scalars().all()
        for tpl in templates:
            tpl.is_recurring = False
            tpl.next_start_at = None

        await session.commit()

        active_names = "\n".join(f"• «{t.name}» (id {t.id})" for t in active) or "—"
        tpl_names = "\n".join(f"• «{t.name}» (id {t.id})" for t in templates) or "—"

        await message.answer(
            f"⏹ <b>Остановлено активных турниров: {len(active)}</b>\n"
            f"{active_names}\n\n"
            f"🔁 <b>Отключено запланированных повторений: {len(templates)}</b>\n"
            f"{tpl_names}\n\n"
            f"Вернуть повтор конкретному шаблону: <code>/toggletour ID</code>",
            parse_mode="HTML",
        )


@router.message(Command("deltour"))
async def cmd_deltour(message: Message, command: CommandObject):
    """Полное удаление шаблона турнира.
    /deltour <template_id>
    Связанные турниры (Tournament) сохраняются, но теряют template_id (история не удаляется)."""
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_admin(role):
            await message.answer("⛔ Только для админа")
            return

        if not command.args:
            await message.answer("Использование: /deltour <template_id>\n\nСписок: /tours")
            return

        try:
            tpl_id = int(command.args.strip())
        except ValueError:
            await message.answer("template_id должен быть числом")
            return

        tpl = await session.get(TournamentTemplate, tpl_id)
        if not tpl:
            await message.answer("Шаблон не найден")
            return

        name = tpl.name

        # отвязываем турниры от шаблона (история сохраняется)
        from sqlalchemy import update as sa_update
        await session.execute(
            sa_update(Tournament)
            .where(Tournament.template_id == tpl_id)
            .values(template_id=None)
        )

        # удаляем шаблон
        await session.delete(tpl)
        await session.commit()

    await message.answer(
        f"🗑 Шаблон турнира «{name}» (id {tpl_id}) <b>полностью удалён</b>.\n"
        f"История турниров сохранена (без привязки к шаблону).",
        parse_mode="HTML",
    )


@router.message(Command("toggletour"))
async def cmd_toggletour(message: Message, command: CommandObject):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_admin(role):
            await message.answer("⛔ Только для админа")
            return
        if not command.args:
            await message.answer("Использование: /toggletour <template_id>")
            return
        try:
            tpl_id = int(command.args.strip())
        except ValueError:
            await message.answer("template_id должен быть числом")
            return
        tpl = await session.get(TournamentTemplate, tpl_id)
        if not tpl:
            await message.answer("Шаблон не найден")
            return
        tpl.is_recurring = not tpl.is_recurring
        if tpl.is_recurring and tpl.is_active:
            tpl.next_start_at = _next_start_from_type(tpl.type, datetime.now(timezone.utc))
        elif not tpl.is_recurring:
            tpl.next_start_at = None
        await session.commit()
        state = "🔁 повтор включён" if tpl.is_recurring else "⏸ повтор выключен"
        await message.answer(
            f"✅ Шаблон «{tpl.name}» (id {tpl.id}): {state}\n"
            f"Следующий запуск: {tpl.next_start_at.strftime('%d.%m %H:%M UTC') if tpl.next_start_at else '—'}",
            parse_mode="HTML",
        )


# ---------- /rewards ----------

@router.message(Command("rewards"))
async def cmd_rewards(message: Message, state: FSMContext):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_admin(role):
            await message.answer("⛔ Только для админа")
            return
        season = await get_active_season(session)
        if not season:
            await message.answer("Нет активного сезона")
            return
        cfg = await get_or_create_config(session, season.id)
        await session.commit()
        text = (
            "⚙️ <b>Настройка наград за активности</b>\n\n"
            f"💬 Комментарий: {cfg.points_comment} очков\n"
            f"   лимит {cfg.daily_limit_comment}/день, кулдаун {cfg.comment_cooldown_seconds}с, "
            f"мин. длина {cfg.min_comment_length}, "
            f"дубликаты {'блок' if cfg.block_duplicate_comments else 'разрешены'}\n"
            f"📢 Подписка: {cfg.points_subscription} очков (однократно)\n"
            f"👥 Реферал: {cfg.points_referral} очков (однократно, "
            f"{'после действия' if cfg.referral_requires_action else 'сразу'})\n\n"
            "Выберите, что изменить:"
        )
        await message.answer(text, parse_mode="HTML", reply_markup=activity_config_keyboard())
        await state.update_data(cfg_season_id=season.id)


@router.callback_query(F.data.startswith("actcfg:"))
async def actcfg_edit(callback: CallbackQuery, state: FSMContext):
    field = callback.data.split(":", 1)[1]
    await state.update_data(cfg_field=field)

    # гарантируем, что cfg_season_id есть в state
    data = await state.get_data()
    season_id = data.get("cfg_season_id")
    if not season_id:
        async with SessionLocal() as session:
            season = await get_active_season(session)
            if not season:
                await callback.answer("Нет активного сезона", show_alert=True)
                return
            season_id = season.id
            await state.update_data(cfg_season_id=season_id)

    if field == "block_duplicate_comments":
        async with SessionLocal() as session:
            cfg = await get_or_create_config(session, season_id)
            cfg.block_duplicate_comments = not cfg.block_duplicate_comments
            await session.commit()
            await callback.answer(f"Дубликаты: {'блок' if cfg.block_duplicate_comments else 'разрешены'}")
            await callback.message.answer(
                f"✅ Дубликаты: {'блокируются' if cfg.block_duplicate_comments else 'разрешены'}"
            )
        return

    if field == "referral_requires_action":
        async with SessionLocal() as session:
            cfg = await get_or_create_config(session, season_id)
            cfg.referral_requires_action = not cfg.referral_requires_action
            await session.commit()
            await callback.answer(f"Реферал: {'после действия' if cfg.referral_requires_action else 'сразу'}")
            await callback.message.answer(
                f"✅ Реферал: {'после действия' if cfg.referral_requires_action else 'сразу'}"
            )
        return

    await state.set_state(ActivityConfigStates.edit_value)
    await callback.answer()
    labels = {
        "points_comment": "очки за комментарий (≥ 0)",
        "points_subscription": "очки за подписку (≥ 0)",
        "points_referral": "очки за реферала (≥ 0)",
        "daily_limit_comment": "дневной лимит комментариев (0 = без лимита)",
        "min_comment_length": "мин. длина комментария (≥ 1)",
        "comment_cooldown_seconds": "кулдаун между комментариями, сек (0 = без)",
    }
    await callback.message.answer(
        f"Введите новое значение: {labels.get(field, field)}\n\n/cancel — отмена"
    )

@router.message(ActivityConfigStates.edit_value)
async def actcfg_save(message: Message, state: FSMContext):
    data = await state.get_data()
    field = data.get("cfg_field")
    season_id = data.get("cfg_season_id")

    if not field:
        await message.answer("Не выбрано поле для изменения. Начните с /rewards")
        await state.clear()
        return

    if not season_id:
        async with SessionLocal() as session:
            season = await get_active_season(session)
            if not season:
                await message.answer("Нет активного сезона")
                await state.clear()
                return
            season_id = season.id

    try:
        value = int((message.text or "").strip())
        if value < 0:
            raise ValueError
        if field == "min_comment_length" and value < 1:
            raise ValueError
    except ValueError:
        await message.answer("Введите целое неотрицательное число (для длины — ≥ 1)")
        return

    async with SessionLocal() as session:
        cfg = await get_or_create_config(session, season_id)
        setattr(cfg, field, value)
        await session.commit()
        await message.answer(f"✅ {field} = {value}")
    await state.clear()


# ---------- Редактирование картинок ----------

@router.callback_query(F.data.startswith("editcase:image:"))
async def editcase_image(callback: CallbackQuery, state: FSMContext):
    case_id = int(callback.data.split(":")[2])
    await state.update_data(image_target="case", image_target_id=case_id)
    await state.set_state(ImageUploadStates.waiting_photo)
    await callback.answer()
    await callback.message.answer(
        "Отправьте картинку для кейса (фото, файл или стикер).\n\n/cancel — отмена"
    )


@router.callback_query(F.data.startswith("itemedit:image:"))
async def itemedit_image(callback: CallbackQuery, state: FSMContext):
    _, _, case_id_s, item_id_s = callback.data.split(":")
    await state.update_data(image_target="item", image_target_id=int(item_id_s))
    await state.set_state(ImageUploadStates.waiting_photo)
    await callback.answer()
    await callback.message.answer(
        "Отправьте картинку для предмета (фото, файл или стикер).\n\n/cancel — отмена"
    )


# ---------- Комментарии в чате ----------

@router.message(F.chat.type.in_({"group", "supergroup"}))
async def on_chat_message(message: Message, redis):
    print(f"[comment] chat={message.chat.id}, text={message.text!r}, from={message.from_user.id if message.from_user else None}")
    if message.from_user is None or message.from_user.is_bot:
        return
    if CHAT_ID is not None and message.chat.id != CHAT_ID:
        return
    if not message.text:
        return
    async with SessionLocal() as session:
        season = await get_active_season(session)
        if not season:
            return
        awarded = await reward_comment(session, redis, season.id, message.from_user.id, message.text)
        if awarded:
            u = await session.get(User, message.from_user.id)
            if u and u.referred_by:
                qualifies = await qualifies_for_referral(session, season.id, message.from_user.id)
                if qualifies:
                    await reward_referral(session, season.id, u.referred_by, message.from_user.id)
        await session.commit()


# ---------- Реферал по входу в группу ----------

@router.chat_member(ChatMemberUpdatedFilter(IS_NOT_MEMBER >> IS_MEMBER))
async def on_user_join(event: ChatMemberUpdated):
    if CHAT_ID is not None and event.chat.id != CHAT_ID:
        return
    if not event.invite_link or not event.invite_link.name:
        return
    name = event.invite_link.name
    if not name.startswith("ref_"):
        return
    try:
        referrer_id = int(name[4:])
    except ValueError:
        return
    new_user_id = event.new_chat_member.user.id
    if referrer_id == new_user_id:
        return
    async with SessionLocal() as session:
        season = await get_active_season(session)
        if not season:
            return
        new_user = await session.get(User, new_user_id)
        if not new_user:
            new_user = User(id=new_user_id, username=event.new_chat_member.user.username)
            session.add(new_user)
            await session.flush()
        if not new_user.referred_by:
            new_user.referred_by = referrer_id
        cfg = await get_or_create_config(session, season.id)
        if not cfg.referral_requires_action:
            await reward_referral(session, season.id, referrer_id, new_user_id)
        await session.commit()
        print(f"[referral] user {new_user_id} joined via ref_{referrer_id}")


# ---------- Бан ----------

@router.message(Command("ban"))
async def cmd_ban(message: Message, command: CommandObject):
    """Забанить пользователя и обнулить его очки/лидерборд.
    /ban <user_id|@username> [причина]"""
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_admin(role):
            await message.answer("⛔ Только для админа")
            return

        if not command.args:
            await message.answer("Использование: /ban <user_id|@username> [причина]")
            return

        parts = command.args.split(maxsplit=1)
        target_raw = parts[0]
        reason = parts[1] if len(parts) > 1 else None

        target = None
        if target_raw.startswith("@"):
            username = target_raw[1:]
            target = (await session.execute(
                select(User).where(User.username == username).limit(1)
            )).scalar_one_or_none()
            if not target:
                await message.answer(f"Пользователь @{username} не найден в БД")
                return
        else:
            try:
                target_id = int(target_raw)
            except ValueError:
                await message.answer("Укажите user_id (число) или @username")
                return
            target = await session.get(User, target_id)
            if not target:
                await message.answer("Пользователь не найден")
                return

        if target.id == message.from_user.id:
            await message.answer("⚠️ Нельзя забанить самого себя")
            return

        if target.role == "admin":
            await message.answer("⚠️ Нельзя забанить админа")
            return

        target.is_banned = True
        target.banned_at = datetime.now(timezone.utc)
        target.ban_reason = reason

        season = await get_active_season(session)
        if season:
            stats = (await session.execute(
                select(UserSeasonStats).where(
                    UserSeasonStats.user_id == target.id,
                    UserSeasonStats.season_id == season.id,
                )
            )).scalar_one_or_none()
            if stats:
                stats.points_balance = 0
                stats.total_quality_score = 0

            active_tournaments = (await session.execute(
                select(Tournament).where(
                    Tournament.season_id == season.id,
                    Tournament.status.in_(["active", "scheduled"]),
                )
            )).scalars().all()
            for t in active_tournaments:
                entry = (await session.execute(
                    select(TournamentEntry).where(
                        TournamentEntry.tournament_id == t.id,
                        TournamentEntry.user_id == target.id,
                    )
                )).scalar_one_or_none()
                if entry:
                    await session.delete(entry)

        await session.commit()

        uname = f"@{target.username}" if target.username else f"id{target.id}"
        await message.answer(
            f"🚫 Пользователь {uname} (<code>{target.id}</code>) забанен.\n"
            f"Причина: {reason or 'не указана'}\n"
            f"Очки обнулены, из активных турниров удалён.",
            parse_mode="HTML",
        )

@router.message(Command("unban"))
async def cmd_unban(message: Message, command: CommandObject):
    """Снять бан. /unban <user_id>"""
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_admin(role):
            await message.answer("⛔ Только для админа")
            return

        if not command.args:
            await message.answer("Использование: /unban <user_id>")
            return

        try:
            target_id = int(command.args.strip())
        except ValueError:
            await message.answer("user_id должен быть числом")
            return

        target = await session.get(User, target_id)
        if not target:
            await message.answer("Пользователь не найден")
            return

        if not target.is_banned:
            await message.answer("Пользователь не забанен")
            return

        target.is_banned = False
        target.banned_at = None
        target.ban_reason = None
        await session.commit()

        await message.answer(f"✅ Пользователь <code>{target_id}</code> разбанен.", parse_mode="HTML")


@router.message(Command("banned"))
async def cmd_banned(message: Message):
    """Список забаненных."""
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_admin(role):
            await message.answer("⛔ Только для админа")
            return

        banned = (await session.execute(
            select(User).where(User.is_banned.is_(True)).order_by(User.banned_at.desc())
        )).scalars().all()

        if not banned:
            await message.answer("Забаненных нет")
            return

        lines = ["🚫 <b>Забаненные:</b>"]
        for u in banned:
            uname = f"@{u.username}" if u.username else "—"
            when = u.banned_at.strftime("%d.%m %H:%M") if u.banned_at else "—"
            reason = u.ban_reason or "—"
            lines.append(f"<code>{u.id}</code> — {uname} — {when} — {reason}")
        await message.answer("\n".join(lines), parse_mode="HTML")


# ---------- Рассылка ----------

from bot.states import BroadcastStates


@router.message(Command("broadcast"))
async def cmd_broadcast(message: Message, state: FSMContext):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_admin(role):
            await message.answer("⛔ Только для админа")
            return
    await state.clear()
    await state.set_state(BroadcastStates.waiting_content)
    await message.answer(
        "📢 Отправьте сообщение для рассылки.\n\n"
        "Можно прикрепить картинку с подписью или отправить текст.\n"
        "HTML-разметка не поддерживается (будет plain text).\n\n"
        "/cancel — отмена"
    )


@router.message(BroadcastStates.waiting_content)
async def broadcast_content(message: Message, state: FSMContext):
    if message.text == "/cancel":
        await state.clear()
        await message.answer("❌ Рассылка отменена")
        return

    if message.photo:
        await state.update_data(
            broadcast_type="photo",
            file_id=message.photo[-1].file_id,
            caption=message.caption or "",
        )
    elif message.text:
        await state.update_data(
            broadcast_type="text",
            text=message.text,
        )
    else:
        await message.answer("Поддерживается только текст или фото с подписью")
        return

    await state.set_state(BroadcastStates.confirm)
    await message.answer(
        "Отправить это сообщение всем пользователям?",
        reply_markup=InlineKeyboardMarkup(inline_keyboard=[
            [InlineKeyboardButton(text="✅ Отправить", callback_data="broadcast:send")],
            [InlineKeyboardButton(text="❌ Отмена", callback_data="broadcast:cancel")],
        ]),
    )


@router.callback_query(F.data == "broadcast:send", StateFilter(BroadcastStates.confirm))
async def broadcast_send(callback: CallbackQuery, state: FSMContext):
    data = await state.get_data()
    await state.clear()

    async with SessionLocal() as session:
        users = (await session.execute(
            select(User).where(User.is_banned.is_(False))
        )).scalars().all()

    await callback.answer("Рассылка началась")
    await callback.message.answer(f"📤 Отправляю {len(users)} пользователям...")

    success = 0
    failed = 0
    for u in users:
        try:
            if data["broadcast_type"] == "photo":
                await callback.bot.send_photo(
                    chat_id=u.id,
                    photo=data["file_id"],
                    caption=data.get("caption") or None,
                )
            else:
                await callback.bot.send_message(
                    chat_id=u.id,
                    text=data["text"],
                )
            success += 1
        except Exception as e:
            failed += 1
            print(f"[broadcast] failed to {u.id}: {e}")
        await asyncio.sleep(0.05)

    await callback.message.answer(f"✅ Готово. Успешно: {success}, ошибок: {failed}")


@router.callback_query(F.data == "broadcast:cancel")
async def broadcast_cancel(callback: CallbackQuery, state: FSMContext):
    await state.clear()
    await callback.answer("Отменено")
    await callback.message.answer("❌ Рассылка отменена")


@router.message(Command("setcaseimage"))
async def cmd_setcaseimage(message: Message, command: CommandObject, state: FSMContext):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_moderator_or_higher(role):
            await message.answer("⛔ Только для модераторов и админов")
            return
    if not command.args:
        await message.answer("Использование: /setcaseimage <case_id>\nЗатем отправьте фото.")
        return
    try:
        case_id = int(command.args.strip())
    except ValueError:
        await message.answer("case_id должен быть числом")
        return
    await state.update_data(image_target="case", image_target_id=case_id)
    await state.set_state(ImageUploadStates.waiting_photo)
    print(f"[setcaseimage] state set to waiting_photo for user {message.from_user.id}")
    await message.answer("Отправьте фото для кейса.\n\n/cancel — отмена")


@router.message(Command("setitemimage"))
async def cmd_setitemimage(message: Message, command: CommandObject, state: FSMContext):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_moderator_or_higher(role):
            await message.answer("⛔ Только для модераторов и админов")
            return
    if not command.args:
        await message.answer("Использование: /setitemimage <item_id>\nЗатем отправьте фото.")
        return
    try:
        item_id = int(command.args.strip())
    except ValueError:
        await message.answer("item_id должен быть числом")
        return
    await state.update_data(image_target="item", image_target_id=item_id)
    await state.set_state(ImageUploadStates.waiting_photo)
    await message.answer("Отправьте фото для предмета.\n\n/cancel — отмена")


@router.message(ImageUploadStates.waiting_photo, F.photo)
async def on_image_upload(message: Message, state: FSMContext):
    data = await state.get_data()
    target = data["image_target"]
    target_id = data["image_target_id"]

    # берём максимальное разрешение
    file = await message.bot.get_file(message.photo[-1].file_id)
    ext = ".png"
    filename = f"{target}_{target_id}_{uuid.uuid4().hex[:8]}{ext}"
    dest = STATIC_IMAGES / filename

    await message.bot.download_file(file.file_path, destination=dest)

    url = f"/static/images/{filename}"

    async with SessionLocal() as session:
        if target == "case":
            from db.models import Case
            obj = await session.get(Case, target_id)
        else:
            from db.models import CaseItem
            obj = await session.get(CaseItem, target_id)
        if not obj:
            await message.answer("Объект не найден")
            await state.clear()
            return
        obj.image_url = url
        await session.commit()

    await message.answer(f"✅ Картинка установлена:\n{url}")
    await state.clear()
    target = data.get("image_target")
    target_id = data.get("image_target_id")
    if target == "case":
        kb = InlineKeyboardMarkup(inline_keyboard=[
            [InlineKeyboardButton(text="↩️ К кейсу", callback_data=f"editcase:back_to:{target_id}")],
        ])
        await message.answer("Вернуться к редактированию кейса:", reply_markup=kb)
    elif target == "item":
        # для предмета нужен case_id, он есть в state? Нет, но можно найти в БД
        async with SessionLocal() as session:
            item = await session.get(CaseItem, target_id)
            if item:
                kb = InlineKeyboardMarkup(inline_keyboard=[
                    [InlineKeyboardButton(text="↩️ К предмету", callback_data=f"itemedit:menu:{item.case_id}:{target_id}")],
                ])
                await message.answer("Вернуться к редактированию предмета:", reply_markup=kb)

@router.message(ImageUploadStates.waiting_photo, F.document)
async def on_image_upload_document(message: Message, state: FSMContext):
    print(f"[upload_doc] got document: mime={message.document.mime_type if message.document else None}, state={await state.get_state()}")
    data = await state.get_data()
    print(f"[upload_doc] state data: {data}")
    target = data.get("image_target")
    target_id = data.get("image_target_id")
    if not target or not target_id:
        await message.answer("Сначала вызовите /setcaseimage или /setitemimage")
        await state.clear()
        return

    if not message.document.mime_type or not message.document.mime_type.startswith("image/"):
        await message.answer("Отправьте PNG или JPEG как файл")
        return

    ext = ".png" if "png" in message.document.mime_type else ".jpg"
    file = await message.bot.get_file(message.document.file_id)
    filename = f"{target}_{target_id}_{uuid.uuid4().hex[:8]}{ext}"
    dest = STATIC_IMAGES / filename
    await message.bot.download_file(file.file_path, destination=dest)

    url = f"/static/images/{filename}"

    async with SessionLocal() as session:
        if target == "case":
            from db.models import Case
            obj = await session.get(Case, target_id)
        else:
            from db.models import CaseItem
            obj = await session.get(CaseItem, target_id)
        if not obj:
            await message.answer("Объект не найден")
            await state.clear()
            return
        obj.image_url = url
        await session.commit()

    await message.answer(f"✅ Картинка установлена:\n{url}")
    target = data.get("image_target")
    target_id = data.get("image_target_id")
    if target == "case":
        kb = InlineKeyboardMarkup(inline_keyboard=[
            [InlineKeyboardButton(text="↩️ К кейсу", callback_data=f"editcase:back_to:{target_id}")],
        ])
        await message.answer("Вернуться к редактированию кейса:", reply_markup=kb)
    elif target == "item":
        # для предмета нужен case_id, он есть в state? Нет, но можно найти в БД
        async with SessionLocal() as session:
            item = await session.get(CaseItem, target_id)
            if item:
                kb = InlineKeyboardMarkup(inline_keyboard=[
                    [InlineKeyboardButton(text="↩️ К предмету", callback_data=f"itemedit:menu:{item.case_id}:{target_id}")],
                ])
                await message.answer("Вернуться к редактированию предмета:", reply_markup=kb)
    await state.clear()


@router.message(ImageUploadStates.waiting_photo, F.sticker)
async def on_sticker_upload(message: Message, state: FSMContext):
    data = await state.get_data()
    target = data.get("image_target")
    target_id = data.get("image_target_id")
    if not target or not target_id:
        await message.answer("Сначала вызовите /setcaseimage или /setitemimage")
        await state.clear()
        return

    # Анимированные стикеры (.tgs/.webm) не подойдут как обычные картинки
    if message.sticker.is_animated or message.sticker.is_video:
        await message.answer("❌ Анимированные стикеры не поддерживаются. Отправьте обычный PNG/WEBP стикер.")
        return

    # Скачиваем стикер (обычно это .webp с прозрачностью)
    file = await message.bot.get_file(message.sticker.file_id)
    # Определяем расширение по пути, который вернул Telegram (обычно .webp)
    ext = ".webp"
    if file.file_path and file.file_path.lower().endswith(".png"):
        ext = ".png"

    filename = f"{target}_{target_id}_{uuid.uuid4().hex[:8]}{ext}"
    dest = STATIC_IMAGES / filename
    await message.bot.download_file(file.file_path, destination=dest)

    url = f"/static/images/{filename}"

    async with SessionLocal() as session:
        if target == "case":
            from db.models import Case
            obj = await session.get(Case, target_id)
        else:
            from db.models import CaseItem
            obj = await session.get(CaseItem, target_id)
        if not obj:
            await message.answer("Объект не найден")
            await state.clear()
            return
        obj.image_url = url
        await session.commit()

    await message.answer(f"✅ Картинка установлена (стикер):\n{url}")
    target = data.get("image_target")
    target_id = data.get("image_target_id")
    if target == "case":
        kb = InlineKeyboardMarkup(inline_keyboard=[
            [InlineKeyboardButton(text="↩️ К кейсу", callback_data=f"editcase:back_to:{target_id}")],
        ])
        await message.answer("Вернуться к редактированию кейса:", reply_markup=kb)
    elif target == "item":
        # для предмета нужен case_id, он есть в state? Нет, но можно найти в БД
        async with SessionLocal() as session:
            item = await session.get(CaseItem, target_id)
            if item:
                kb = InlineKeyboardMarkup(inline_keyboard=[
                    [InlineKeyboardButton(text="↩️ К предмету", callback_data=f"itemedit:menu:{item.case_id}:{target_id}")],
                ])
                await message.answer("Вернуться к редактированию предмета:", reply_markup=kb)
    await state.clear()

@router.message(NewCaseStates.add_item_image, F.photo)
async def newcase_item_image_photo(message: Message, state: FSMContext):
    await _save_item_image_and_finish(message, state, message.photo[-1], "photo")


@router.message(NewCaseStates.add_item_image, F.sticker)
async def newcase_item_image_sticker(message: Message, state: FSMContext):
    if message.sticker.is_animated or message.sticker.is_video:
        await message.answer("Анимированные стикеры не поддерживаются. Отправьте обычный стикер или пропустите.")
        return
    await _save_item_image_and_finish(message, state, message.sticker, "sticker")


@router.message(NewCaseStates.add_item_image, F.document)
async def newcase_item_image_document(message: Message, state: FSMContext):
    if not message.document.mime_type or not message.document.mime_type.startswith("image/"):
        await message.answer("Отправьте PNG/JPEG как файл или пропустите.")
        return
    await _save_item_image_and_finish(message, state, message.document, "document")


@router.callback_query(F.data == "newcase:skip_image", StateFilter(NewCaseStates.add_item_image))
async def newcase_skip_image(callback: CallbackQuery, state: FSMContext):
    await _finish_item_creation(callback.message, state, image_url=None)
    await callback.answer()


async def _save_item_image_and_finish(message: Message, state: FSMContext, file_obj, file_type: str):
    data = await state.get_data()
    adding = data.get("adding_item", {})

    try:
        file = await message.bot.get_file(file_obj.file_id)
        ext = ".webp"
        if file_type == "document" and file_obj.file_name and file_obj.file_name.lower().endswith(".png"):
            ext = ".png"
        elif file_type == "photo":
            ext = ".jpg"
        filename = f"item_{uuid.uuid4().hex[:8]}{ext}"
        dest = STATIC_IMAGES / filename
        await message.bot.download_file(file.file_path, destination=dest)
        image_url = f"/static/images/{filename}"
    except Exception as e:
        await message.answer(f"Не удалось загрузить картинку: {e}")
        return

    await _finish_item_creation(message, state, image_url=image_url)


async def _finish_item_creation(message: Message, state: FSMContext, image_url: str | None):
    data = await state.get_data()
    adding = data.get("adding_item", {})
    adding["image_url"] = image_url
    items = data.get("items", [])
    items.append(adding)
    await state.update_data(items=items, adding_item={}, step=None)
    await state.set_state(NewCaseStates.items)

    lines = [
        f"✅ Предмет добавлен: {adding['name']} ({adding['rarity']}, вес {adding['weight']}, награда {adding['point_value']})",
        f"Картинка: {'загружена' if image_url else 'заглушка'}",
        f"\nВсего предметов: {len(items)}",
    ]
    await message.answer("\n".join(lines), reply_markup=items_keyboard())

@router.message(EditCaseStates.add_item_image, F.photo)
async def editcase_item_image_photo(message: Message, state: FSMContext):
    await _save_edit_item_image_and_finish(message, state, message.photo[-1], "photo")


@router.message(EditCaseStates.add_item_image, F.sticker)
async def editcase_item_image_sticker(message: Message, state: FSMContext):
    if message.sticker.is_animated or message.sticker.is_video:
        await message.answer("Анимированные стикеры не поддерживаются. Отправьте обычный стикер или пропустите.")
        return
    await _save_edit_item_image_and_finish(message, state, message.sticker, "sticker")


@router.message(EditCaseStates.add_item_image, F.document)
async def editcase_item_image_document(message: Message, state: FSMContext):
    if not message.document.mime_type or not message.document.mime_type.startswith("image/"):
        await message.answer("Отправьте PNG/JPEG как файл или пропустите.")
        return
    await _save_edit_item_image_and_finish(message, state, message.document, "document")


@router.callback_query(F.data == "editcase:skip_item_image", StateFilter(EditCaseStates.add_item_image))
async def editcase_skip_item_image(callback: CallbackQuery, state: FSMContext):
    await _finish_edit_item_creation(callback.message, state, image_url=None)
    await callback.answer()


async def _save_edit_item_image_and_finish(message: Message, state: FSMContext, file_obj, file_type: str):
    data = await state.get_data()
    try:
        file = await message.bot.get_file(file_obj.file_id)
        ext = ".webp"
        if file_type == "document" and file_obj.file_name and file_obj.file_name.lower().endswith(".png"):
            ext = ".png"
        elif file_type == "photo":
            ext = ".jpg"
        filename = f"item_{uuid.uuid4().hex[:8]}{ext}"
        dest = STATIC_IMAGES / filename
        await message.bot.download_file(file.file_path, destination=dest)
        image_url = f"/static/images/{filename}"
    except Exception as e:
        await message.answer(f"Не удалось загрузить картинку: {e}")
        return
    await _finish_edit_item_creation(message, state, image_url=image_url)


async def _finish_edit_item_creation(message: Message, state: FSMContext, image_url: str | None):
    data = await state.get_data()
    adding = data.get("edit_adding_item", {})
    case_id = data["edit_case_id"]

    async with SessionLocal() as session:
        item = CaseItem(
            case_id=case_id,
            name=adding["name"],
            rarity=adding["rarity"],
            weight=adding["weight"],
            quality_score=adding.get("quality_score", 1),
            point_value=adding["point_value"],
            image_url=image_url,
        )
        session.add(item)
        await session.commit()
        item_id = item.id

    await message.answer(
        f"✅ Предмет «{adding['name']}» добавлен (картинка: {'есть' if image_url else 'заглушка'})",
        reply_markup=InlineKeyboardMarkup(inline_keyboard=[
            [InlineKeyboardButton(text="↩️ К кейсу", callback_data=f"editcase:back_to:{case_id}")],
        ]),
    )
    await state.clear()


# ---------- Качество (Float) и StatTrak ----------

@router.message(Command("quality"))
async def cmd_quality(message: Message, state: FSMContext):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_admin(role):
            await message.answer("⛔ Только для админа")
            return
        season = await get_active_season(session)
        if not season:
            await message.answer("Нет активного сезона")
            return
        cfg = await get_or_create_config(session, season.id)
        await session.commit()

        total_w = (cfg.quality_weight_fn + cfg.quality_weight_mw + cfg.quality_weight_ft
                   + cfg.quality_weight_ww + cfg.quality_weight_bs) or 1

        text = (
            "⚙️ <b>Качество (Float) и StatTrak</b>\n\n"
            f"FN: вес {cfg.quality_weight_fn} ({cfg.quality_weight_fn/total_w*100:.1f}%) × {cfg.mult_fn}\n"
            f"MW: вес {cfg.quality_weight_mw} ({cfg.quality_weight_mw/total_w*100:.1f}%) × {cfg.mult_mw}\n"
            f"FT: вес {cfg.quality_weight_ft} ({cfg.quality_weight_ft/total_w*100:.1f}%) × {cfg.mult_ft}\n"
            f"WW: вес {cfg.quality_weight_ww} ({cfg.quality_weight_ww/total_w*100:.1f}%) × {cfg.mult_ww}\n"
            f"BS: вес {cfg.quality_weight_bs} ({cfg.quality_weight_bs/total_w*100:.1f}%) × {cfg.mult_bs}\n\n"
            f"StatTrak: шанс {cfg.stattrak_chance}%, множитель × {cfg.stattrak_multiplier}\n\n"
            "Что изменить?"
        )
        kb = InlineKeyboardMarkup(inline_keyboard=[
            [InlineKeyboardButton(text="🎲 Веса качества (FN MW FT WW + авто BS)", callback_data="quality:weights")],
            [InlineKeyboardButton(text="💲 Множители качества", callback_data="quality:multipliers")],
            [InlineKeyboardButton(text="⭐ StatTrak", callback_data="quality:stattrak")],
        ])
        await message.answer(text, parse_mode="HTML", reply_markup=kb)
        await state.update_data(cfg_season_id=season.id)


@router.callback_query(F.data == "quality:weights")
async def quality_weights_start(callback: CallbackQuery, state: FSMContext):
    await callback.answer()
    await callback.message.answer(
        "Введите 4 веса через пробел: <b>FN MW FT WW</b>\n"
        "Вес BS будет рассчитан автоматически (100 − сумма).\n\n"
        "Например: <code>10 20 50 15</code>\n\n/cancel — отмена",
        parse_mode="HTML",
    )
    await state.set_state(ActivityConfigStates.edit_quality_weights)


@router.message(ActivityConfigStates.edit_quality_weights)
async def quality_weights_save(message: Message, state: FSMContext):
    if message.text == "/cancel":
        await state.clear()
        await message.answer("❌ Отменено")
        return
    try:
        parts = [int(x) for x in (message.text or "").split()]
        if len(parts) != 4:
            raise ValueError
        fn, mw, ft, ww = parts
        if any(v < 0 for v in parts):
            raise ValueError
        bs = 100 - (fn + mw + ft + ww)
        if bs < 0:
            await message.answer("Сумма первых 4 весов больше 100. Введите заново.")
            return
    except ValueError:
        await message.answer("Введите 4 целых неотрицательных числа через пробел.")
        return

    data = await state.get_data()
    async with SessionLocal() as session:
        cfg = await get_or_create_config(session, data["cfg_season_id"])
        cfg.quality_weight_fn = fn
        cfg.quality_weight_mw = mw
        cfg.quality_weight_ft = ft
        cfg.quality_weight_ww = ww
        cfg.quality_weight_bs = bs
        await session.commit()
    await message.answer(
        f"✅ Сохранено:\nFN={fn}, MW={mw}, FT={ft}, WW={ww}\n"
        f"<b>BS={bs}</b> (рассчитан автоматически, сумма = 100)",
        parse_mode="HTML",
    )
    await state.clear()


@router.callback_query(F.data == "quality:multipliers")
async def quality_mult_start(callback: CallbackQuery, state: FSMContext):
    await callback.answer()
    await callback.message.answer(
        "Введите 5 множителей через пробел: <b>FN MW FT WW BS</b>\n"
        "Например: <code>1.45 1.15 0.85 0.65 0.5</code>\n\n/cancel — отмена",
        parse_mode="HTML",
    )
    await state.set_state(ActivityConfigStates.edit_quality_mults)


@router.message(ActivityConfigStates.edit_quality_mults)
async def quality_mult_save(message: Message, state: FSMContext):
    if message.text == "/cancel":
        await state.clear()
        await message.answer("❌ Отменено")
        return
    try:
        parts = [float(x) for x in (message.text or "").split()]
        if len(parts) != 5:
            raise ValueError
        fn, mw, ft, ww, bs = parts
    except ValueError:
        await message.answer("Введите 5 чисел через пробел.")
        return
    data = await state.get_data()
    async with SessionLocal() as session:
        cfg = await get_or_create_config(session, data["cfg_season_id"])
        cfg.mult_fn = fn
        cfg.mult_mw = mw
        cfg.mult_ft = ft
        cfg.mult_ww = ww
        cfg.mult_bs = bs
        await session.commit()
    await message.answer(
        f"✅ Множители сохранены:\nFN×{fn}, MW×{mw}, FT×{ft}, WW×{ww}, BS×{bs}",
        parse_mode="HTML",
    )
    await state.clear()


@router.callback_query(F.data == "quality:stattrak")
async def quality_stattrak_start(callback: CallbackQuery, state: FSMContext):
    await callback.answer()
    await callback.message.answer(
        "Введите через пробел: <b>шанс_% множитель</b>\n"
        "Например: <code>10 2.0</code> (10% шанс, ×2 к цене)\n\n/cancel — отмена",
        parse_mode="HTML",
    )
    await state.set_state(ActivityConfigStates.edit_stattrak)


@router.message(ActivityConfigStates.edit_stattrak)
async def quality_stattrak_save(message: Message, state: FSMContext):
    if message.text == "/cancel":
        await state.clear()
        await message.answer("❌ Отменено")
        return
    try:
        parts = (message.text or "").split()
        if len(parts) != 2:
            raise ValueError
        chance = int(parts[0])
        mult = float(parts[1])
        if chance < 0 or chance > 100 or mult <= 0:
            raise ValueError
    except ValueError:
        await message.answer("Формат: <шанс 0-100> <множитель > 0>. Например: 10 2.0")
        return
    data = await state.get_data()
    async with SessionLocal() as session:
        cfg = await get_or_create_config(session, data["cfg_season_id"])
        cfg.stattrak_chance = chance
        cfg.stattrak_multiplier = mult
        await session.commit()
    await message.answer(f"✅ StatTrak: шанс {chance}%, множитель ×{mult}")
    await state.clear()


@router.message(Command("wipeinventory"))
async def cmd_wipeinventory(message: Message):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_admin(role):
            await message.answer("⛔ Только для админа")
            return
    await message.answer(
        "⚠️ Это удалит ВСЕ предметы из инвентаря у ВСЕХ пользователей.\n"
        "Продолжить?",
        reply_markup=InlineKeyboardMarkup(inline_keyboard=[
            [InlineKeyboardButton(text="🗑 Да, очистить всё", callback_data="wipe:confirm")],
            [InlineKeyboardButton(text="❌ Отмена", callback_data="wipe:cancel")],
        ]),
    )


@router.callback_query(F.data == "wipe:confirm")
async def wipe_confirm(callback: CallbackQuery):
    async with SessionLocal() as session:
        role = await get_role(session, callback.from_user.id)
        if not is_admin(role):
            await callback.answer("⛔ Только для админа", show_alert=True)
            return
        from sqlalchemy import update
        await session.execute(update(Drop).where(Drop.is_sold.is_(False)).values(is_sold=True))
        await session.commit()
    await callback.answer("Готово")
    await callback.message.answer("🧹 Инвентарь всех пользователей очищен (предметы помечены как проданные).")


@router.callback_query(F.data == "wipe:cancel")
async def wipe_cancel(callback: CallbackQuery):
    await callback.answer("Отменено")
    await callback.message.answer("❌ Очистка отменена.")


@router.callback_query(F.data.startswith("edittour:nicklen:"))
async def edittour_nicklen(callback: CallbackQuery, state: FSMContext):
    tpl_id = int(callback.data.split(":")[2])
    await state.update_data(edit_tpl_id=tpl_id)
    await state.set_state(EditTourStates.edit_nicklen)
    await callback.answer()
    await callback.message.answer(
        "Введите максимальную длину никнейма в лидерборде (например, 15):\n\n/cancel — отмена"
    )


@router.message(EditTourStates.edit_nicklen)
async def edittour_nicklen_save(message: Message, state: FSMContext):
    if message.text == "/cancel":
        await state.clear()
        await message.answer("❌ Отменено")
        return
    try:
        n = int((message.text or "").strip())
        if n < 3:
            raise ValueError
    except ValueError:
        await message.answer("Введите целое число ≥ 3")
        return
    data = await state.get_data()
    tpl_id = data["edit_tpl_id"]
    async with SessionLocal() as session:
        tpl = await session.get(TournamentTemplate, tpl_id)
        if not tpl:
            await message.answer("Шаблон не найден")
            await state.clear()
            return
        tpl.nickname_max_length = n
        await session.flush()  # <-- важно: фиксируем значение в сессии
        await _sync_active_tournaments(session, tpl_id)  # <-- синхронизация
        await session.commit()
    await message.answer(f"✅ Макс. длина никнейма: {n} (применено к активным турнирам)")
    await state.clear()


@router.callback_query(F.data.startswith("edittour:labels:"))
async def edittour_labels(callback: CallbackQuery, state: FSMContext):
    tpl_id = int(callback.data.split(":")[2])
    async with SessionLocal() as session:
        tpl = await session.get(TournamentTemplate, tpl_id)
        if not tpl:
            await callback.answer("Шаблон не найден", show_alert=True)
            return
        top_n = tpl.top_n
    await state.update_data(edit_tpl_id=tpl_id, labels_buffer={}, label_place=1, label_top_n=top_n)
    await state.set_state(EditTourStates.edit_labels)
    await callback.answer()
    await callback.message.answer(
        f"Настроим тексты призов для мест 1..{top_n}.\n\n"
        f"Введите текст для <b>1</b>-го места (или /skip чтобы пропустить):\n\n/cancel — отмена",
        parse_mode="HTML",
    )


@router.message(EditTourStates.edit_labels)
async def edittour_labels_step(message: Message, state: FSMContext):
    data = await state.get_data()
    place = data.get("label_place", 1)
    top_n = data.get("label_top_n", 1)
    buffer = data.get("labels_buffer", {})

    if message.text == "/cancel":
        await state.clear()
        await message.answer("❌ Отменено")
        return

    if message.text != "/skip":
        text = (message.text or "").strip()
        if text:
            buffer[str(place)] = text

    if place >= top_n:
        tpl_id = data["edit_tpl_id"]
        async with SessionLocal() as session:
            tpl = await session.get(TournamentTemplate, tpl_id)
            if tpl:
                tpl.leaderboard_labels = buffer
                await session.flush()
                await _sync_active_tournaments(session, tpl_id)
                await session.commit()
        await message.answer(
            f"✅ Тексты сохранены и применены к активным турнирам: {buffer}"
        )
        await state.clear()
        return

    await state.update_data(labels_buffer=buffer, label_place=place + 1)
    await message.answer(
        f"Введите текст для <b>{place + 1}</b>-го места (или /skip):\n\n/cancel — отмена",
        parse_mode="HTML",
    )

@router.message(Command("edittour"))
async def cmd_edittour(message: Message, command: CommandObject, state: FSMContext):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_moderator_or_higher(role):
            await message.answer("⛔ Только для модераторов и админов")
            return

    if not command.args:
        await message.answer("Использование: /edittour <template_id>\n\nСписок: /tours")
        return
    try:
        tpl_id = int(command.args.strip())
    except ValueError:
        await message.answer("template_id должен быть числом")
        return

    async with SessionLocal() as session:
        tpl = await session.get(TournamentTemplate, tpl_id)
        if not tpl:
            await message.answer("Шаблон не найден")
            return
        await message.answer(
            f"✏️ Шаблон <b>{tpl.name}</b> (id {tpl.id})\n"
            f"type: {tpl.type}, duration: {tpl.duration_hours}ч\n"
            f"top_n (победителей): {tpl.top_n}\n"
            f"display_limit (показывать в топе): {tpl.display_limit}\n"
            f"min_score: {tpl.min_score}\n"
            f"rewards: {tpl.reward_config}\n"
            f"nickname_max_length: {tpl.nickname_max_length}\n"
            f"labels: {tpl.leaderboard_labels}\n"
            f"recurring: {tpl.is_recurring}, active: {tpl.is_active}",
            parse_mode="HTML",
            reply_markup=edit_tour_keyboard(tpl.id),
        )
        await state.update_data(edit_tpl_id=tpl.id)


# ---------- /edittour — настройки ----------

async def _sync_active_tournaments(session, tpl_id: int):
    from sqlalchemy import update as sa_update
    tpl = await session.get(TournamentTemplate, tpl_id)
    print(f"[sync] tpl_id={tpl_id}, tpl={tpl.name if tpl else None}, nickname={tpl.nickname_max_length if tpl else None}, labels={tpl.leaderboard_labels if tpl else None}")
    if not tpl:
        return
    result = await session.execute(
        sa_update(Tournament)
        .where(Tournament.template_id == tpl_id, Tournament.status == "active")
        .values(
            top_n=tpl.top_n,
            display_limit=tpl.display_limit,
            min_score=tpl.min_score,
            score_multiplier=tpl.score_multiplier or {},
            reward_config=tpl.reward_config or {},
            nickname_max_length=tpl.nickname_max_length,
            leaderboard_labels=tpl.leaderboard_labels or {},
        )
    )
    print(f"[sync] rows affected: {result.rowcount}")


@router.callback_query(F.data.startswith("edittour:top_n:"))
async def edittour_top_n(callback: CallbackQuery, state: FSMContext):
    tpl_id = int(callback.data.split(":")[2])
    await state.update_data(edit_tpl_id=tpl_id)
    await state.set_state(EditTourStates.edit_top_n)
    await callback.answer()
    await callback.message.answer("Введите количество победителей (top_n, целое > 0):\n\n/cancel — отмена")


@router.message(EditTourStates.edit_top_n)
async def edittour_top_n_save(message: Message, state: FSMContext):
    if message.text == "/cancel":
        await state.clear()
        await message.answer("❌ Отменено")
        return
    try:
        n = int((message.text or "").strip())
        if n <= 0:
            raise ValueError
    except ValueError:
        await message.answer("top_n — целое > 0")
        return
    data = await state.get_data()
    tpl_id = data["edit_tpl_id"]
    async with SessionLocal() as session:
        tpl = await session.get(TournamentTemplate, tpl_id)
        if not tpl:
            await message.answer("Шаблон не найден")
            await state.clear()
            return
        tpl.top_n = n
        await _sync_active_tournaments(session, tpl_id)
        await session.commit()
    await message.answer(f"✅ top_n = {n} (применено к активным турнирам)")
    await state.clear()


@router.callback_query(F.data.startswith("edittour:display_limit:"))
async def edittour_display_limit(callback: CallbackQuery, state: FSMContext):
    tpl_id = int(callback.data.split(":")[2])
    await state.update_data(edit_tpl_id=tpl_id)
    await state.set_state(EditTourStates.edit_display_limit)
    await callback.answer()
    await callback.message.answer("Сколько участников показывать в топе (display_limit, целое > 0):\n\n/cancel — отмена")


@router.message(EditTourStates.edit_display_limit)
async def edittour_display_limit_save(message: Message, state: FSMContext):
    if message.text == "/cancel":
        await state.clear()
        await message.answer("❌ Отменено")
        return
    try:
        n = int((message.text or "").strip())
        if n <= 0:
            raise ValueError
    except ValueError:
        await message.answer("display_limit — целое > 0")
        return
    data = await state.get_data()
    tpl_id = data["edit_tpl_id"]
    async with SessionLocal() as session:
        tpl = await session.get(TournamentTemplate, tpl_id)
        if not tpl:
            await message.answer("Шаблон не найден")
            await state.clear()
            return
        tpl.display_limit = n
        await _sync_active_tournaments(session, tpl_id)
        await session.commit()
    await message.answer(f"✅ display_limit = {n} (применено к активным турнирам)")
    await state.clear()


@router.callback_query(F.data.startswith("edittour:rewards:"))
async def edittour_rewards(callback: CallbackQuery, state: FSMContext):
    tpl_id = int(callback.data.split(":")[2])
    await state.update_data(edit_tpl_id=tpl_id, rewards_input={}, current_place=1)
    await state.set_state(EditTourStates.edit_rewards_step)
    await callback.answer()
    await callback.message.answer(
        "Пошагово настроим награды по местам.\n"
        "Введите награду для 1-го места в формате:\n"
        "<code>100</code> — только очки\n"
        "<code>100 + Скин</code> — очки + ручная награда\n"
        "<code>0 + Скин</code> — только ручная награда\n\n"
        "/done — закончить\n/cancel — отмена",
        parse_mode="HTML",
    )


@router.message(EditTourStates.edit_rewards_step)
async def edittour_rewards_step(message: Message, state: FSMContext):
    if message.text == "/cancel":
        await state.clear()
        await message.answer("❌ Отменено")
        return

    data = await state.get_data()

    if message.text == "/done":
        rewards = data.get("rewards_input", {})
        tpl_id = data["edit_tpl_id"]
        async with SessionLocal() as session:
            tpl = await session.get(TournamentTemplate, tpl_id)
            if tpl:
                tpl.reward_config = rewards
                await _sync_active_tournaments(session, tpl_id)
                await session.commit()
        await message.answer(f"✅ Награды сохранены и применены к активным турнирам: {rewards}")
        await state.clear()
        return

    place = data.get("current_place", 1)
    text = (message.text or "").strip()
    points = 0
    manual = None
    if "+" in text:
        parts = [p.strip() for p in text.split("+", 1)]
        try:
            points = int(parts[0])
        except ValueError:
            await message.answer("Очки должны быть числом")
            return
        manual = parts[1] or None
    else:
        try:
            points = int(text)
        except ValueError:
            await message.answer("Введите число, '100 + Скин' или /done")
            return

    rewards = data.get("rewards_input", {})
    entry = {"points": points}
    if manual:
        entry["manual"] = manual
    rewards[str(place)] = entry
    await state.update_data(rewards_input=rewards, current_place=place + 1)
    await message.answer(f"Место {place}: {entry}\n\nВведите награду для {place + 1}-го места или /done")


@router.callback_query(F.data.startswith("edittour:toggle_recurring:"))
async def edittour_toggle_recurring(callback: CallbackQuery):
    tpl_id = int(callback.data.split(":")[2])
    async with SessionLocal() as session:
        tpl = await session.get(TournamentTemplate, tpl_id)
        if not tpl:
            await callback.answer("Шаблон не найден", show_alert=True)
            return
        tpl.is_recurring = not tpl.is_recurring
        if tpl.is_recurring and tpl.is_active:
            tpl.next_start_at = _next_start_from_type(tpl.type, datetime.now(timezone.utc))
        elif not tpl.is_recurring:
            tpl.next_start_at = None
        await session.commit()
    await callback.answer(f"Повтор: {'вкл' if tpl.is_recurring else 'выкл'}")
    await callback.message.answer(
        f"✅ Повтор: {'🔁 включён' if tpl.is_recurring else '⏸ выключен'}\n"
        f"Следующий запуск: {tpl.next_start_at.strftime('%d.%m %H:%M UTC') if tpl.next_start_at else '—'}"
    )


@router.callback_query(F.data.startswith("edittour:nicklen:"))
async def edittour_nicklen(callback: CallbackQuery, state: FSMContext):
    tpl_id = int(callback.data.split(":")[2])
    await state.update_data(edit_tpl_id=tpl_id)
    await state.set_state(EditTourStates.edit_nicklen)
    await callback.answer()
    await callback.message.answer("Введите максимальную длину никнейма в лидерборде (например, 15):\n\n/cancel — отмена")



@router.callback_query(F.data.startswith("edittour:labels:"))
async def edittour_labels(callback: CallbackQuery, state: FSMContext):
    tpl_id = int(callback.data.split(":")[2])
    async with SessionLocal() as session:
        tpl = await session.get(TournamentTemplate, tpl_id)
        if not tpl:
            await callback.answer("Шаблон не найден", show_alert=True)
            return
        top_n = tpl.top_n
    await state.update_data(edit_tpl_id=tpl_id, labels_buffer={}, label_place=1, label_top_n=top_n)
    await state.set_state(EditTourStates.edit_labels)
    await callback.answer()
    await callback.message.answer(
        f"Настроим тексты призов для мест 1..{top_n}.\n\n"
        f"Введите текст для <b>1</b>-го места (или /skip чтобы пропустить):\n\n/cancel — отмена",
        parse_mode="HTML",
    )


@router.message(EditTourStates.edit_labels)
async def edittour_labels_step(message: Message, state: FSMContext):
    data = await state.get_data()
    place = data.get("label_place", 1)
    top_n = data.get("label_top_n", 1)
    buffer = data.get("labels_buffer", {})

    if message.text == "/cancel":
        await state.clear()
        await message.answer("❌ Отменено")
        return

    if message.text != "/skip":
        text = (message.text or "").strip()
        if text:
            buffer[str(place)] = text

    if place >= top_n:
        async with SessionLocal() as session:
            tpl = await session.get(TournamentTemplate, data["edit_tpl_id"])
            if tpl:
                tpl.leaderboard_labels = buffer
                await _sync_active_tournaments(session, data["edit_tpl_id"])
                await session.commit()
        await message.answer(f"✅ Тексты сохранены и применены к активным турнирам: {buffer}")
        await state.clear()
        return

    await state.update_data(labels_buffer=buffer, label_place=place + 1)
    await message.answer(
        f"Введите текст для <b>{place + 1}</b>-го места (или /skip):\n\n/cancel — отмена",
        parse_mode="HTML",
    )


# ---------- Правила ----------

@router.message(Command("rules"))
async def cmd_rules(message: Message, state: FSMContext):
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_admin(role):
            await message.answer("⛔ Только для админа")
            return
        season = await get_active_season(session)
        if not season:
            await message.answer("Нет активного сезона")
            return
        await state.update_data(rules_season_id=season.id)
        enabled = season.rules_enabled
        preview = (season.rules_text or "")[:300]

    status = "✅ включены" if enabled else "⏸ выключены"
    text = (
        f"📜 <b>Правила</b>\n\n"
        f"Статус: {status}\n\n"
        f"Текущий текст:\n<pre>{preview or '—'}</pre>"
    )
    kb = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="✏️ Изменить текст", callback_data="rules:edit")],
        [InlineKeyboardButton(
            text="⏸ Выключить" if enabled else "▶️ Включить",
            callback_data="rules:toggle",
        )],
    ])
    await message.answer(text, parse_mode="HTML", reply_markup=kb)


@router.callback_query(F.data == "rules:edit")
async def rules_edit(callback: CallbackQuery, state: FSMContext):
    await state.set_state(RulesStates.edit_text)
    await callback.answer()
    await callback.message.answer(
        "Введите новый текст правил (plain text, переносы строк сохранятся).\n\n/cancel — отмена"
    )


@router.message(RulesStates.edit_text)
async def rules_edit_save(message: Message, state: FSMContext):
    if message.text == "/cancel":
        await state.clear()
        await message.answer("❌ Отменено")
        return
    text = (message.text or "").strip()
    if not text:
        await message.answer("Текст пустой")
        return
    data = await state.get_data()
    async with SessionLocal() as session:
        season = await session.get(Season, data["rules_season_id"])
        if season:
            season.rules_text = text
            await session.commit()
    await message.answer(f"✅ Текст правил сохранён ({len(text)} символов)")
    await state.clear()


@router.callback_query(F.data == "rules:toggle")
async def rules_toggle(callback: CallbackQuery):
    async with SessionLocal() as session:
        season = await get_active_season(session)
        if not season:
            await callback.answer("Нет активного сезона", show_alert=True)
            return
        season.rules_enabled = not season.rules_enabled
        await session.commit()
        status = "✅ включены" if season.rules_enabled else "⏸ выключены"
    await callback.answer(status)
    await callback.message.answer(f"Правила теперь {status}")


# ---------- Очистка баланса ----------

# ---------- Очистка и установка баланса ----------

@router.message(Command("wipebalance"))
async def cmd_wipebalance(message: Message, command: CommandObject, state: FSMContext):
    """Обнулить баланс ВСЕХ пользователей и установить им новое значение.
    /wipebalance <новое_значение>"""
    async with SessionLocal() as session:
        role = await get_role(session, message.from_user.id)
        if not is_admin(role):
            await message.answer("⛔ Только для админа")
            return
        season = await get_active_season(session)
        if not season:
            await message.answer("Нет активного сезона")
            return

        users_count = (await session.execute(
            select(func.count(UserSeasonStats.id)).where(
                UserSeasonStats.season_id == season.id,
            )
        )).scalar_one()

    # Новое значение обязательно
    if not command.args:
        await message.answer(
            "Использование: /wipebalance <новое_значение>\n\n"
            "Пример: /wipebalance 500 — обнулит и установит 500 всем пользователям."
        )
        return

    try:
        new_value = int(command.args.strip())
        if new_value < 0:
            raise ValueError
    except ValueError:
        await message.answer("Значение должно быть целым числом ≥ 0.\nФормат: /wipebalance <новое_значение>")
        return

    await state.update_data(
        wipe_season_id=season.id,
        wipe_new_value=new_value,
    )
    await state.set_state(WipeBalanceStates.confirm)

    await message.answer(
        f"⚠️ <b>Сброс и установка баланса</b>\n\n"
        f"Сезон: <b>{season.name}</b>\n"
        f"Затронет пользователей: <b>{users_count}</b>\n"
        f"Новый баланс для ВСЕХ: <b>{new_value}</b> 🪙\n\n"
        f"Текущий баланс каждого будет обнулён, затем установлен в <b>{new_value}</b>.\n\n"
        f"Продолжить?",
        parse_mode="HTML",
        reply_markup=InlineKeyboardMarkup(inline_keyboard=[
            [InlineKeyboardButton(text="🗑 Да, установить всем", callback_data="wipebalance:confirm")],
            [InlineKeyboardButton(text="❌ Отмена", callback_data="wipebalance:cancel")],
        ]),
    )


@router.callback_query(F.data == "wipebalance:confirm")
async def wipebalance_confirm(callback: CallbackQuery, state: FSMContext):
    data = await state.get_data()
    await state.clear()

    season_id = data.get("wipe_season_id")
    new_value = data.get("wipe_new_value")

    if not season_id or new_value is None:
        await callback.answer("Данные утеряны, начните заново", show_alert=True)
        return

    async with SessionLocal() as session:
        role = await get_role(session, callback.from_user.id)
        if not is_admin(role):
            await callback.answer("⛔ Только для админа", show_alert=True)
            return

        from sqlalchemy import update as sa_update

        # 1) Обнуляем всех в сезоне
        await session.execute(
            sa_update(UserSeasonStats)
            .where(UserSeasonStats.season_id == season_id)
            .values(points_balance=0)
        )

        # 2) Устанавливаем новое значение всем
        await session.execute(
            sa_update(UserSeasonStats)
            .where(UserSeasonStats.season_id == season_id)
            .values(points_balance=new_value)
        )

        # 3) Логируем для админа (для истории)
        session.add(PointTransaction(
            season_id=season_id,
            user_id=callback.from_user.id,
            amount=new_value,
            source="manual",
            meta={"reason": "wipebalance", "admin_id": callback.from_user.id, "new_value": new_value},
        ))

        await session.commit()

        total_users = (await session.execute(
            select(func.count(UserSeasonStats.id)).where(
                UserSeasonStats.season_id == season_id,
            )
        )).scalar_one()

    await callback.answer("Готово")
    await callback.message.answer(
        f"✅ <b>Готово</b>\n\n"
        f"Баланс <b>{total_users}</b> пользователей установлен в <b>{new_value}</b> 🪙",
        parse_mode="HTML",
    )


@router.callback_query(F.data == "wipebalance:cancel")
async def wipebalance_cancel(callback: CallbackQuery, state: FSMContext):
    await state.clear()
    await callback.answer("Отменено")
    await callback.message.answer("❌ Операция отменена.")