from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton


RARITIES = [
    "Consumer", "Industrial", "Mil-Spec", "Restricted",
    "Classified", "Covert", "Rare Special", "Contraband",
]


def items_keyboard() -> InlineKeyboardMarkup:
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="➕ Добавить предмет", callback_data="newcase:add_item")],
        [InlineKeyboardButton(text="✅ Завершить создание", callback_data="newcase:finish")],
        [InlineKeyboardButton(text="❌ Отмена", callback_data="newcase:cancel")],
    ])


def confirm_keyboard() -> InlineKeyboardMarkup:
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="✅ Создать", callback_data="newcase:confirm")],
        [InlineKeyboardButton(text="❌ Отмена", callback_data="newcase:cancel")],
    ])


def rarity_keyboard() -> InlineKeyboardMarkup:
    rows = []
    for i in range(0, len(RARITIES), 2):
        pair = RARITIES[i:i+2]
        rows.append([InlineKeyboardButton(text=r, callback_data=f"rarity:{r}") for r in pair])
    rows.append([InlineKeyboardButton(text="❌ Отмена", callback_data="newcase:cancel")])
    return InlineKeyboardMarkup(inline_keyboard=rows)


def rarity_keyboard_for_item(case_id: int, item_id: int) -> InlineKeyboardMarkup:
    rows = []
    for i in range(0, len(RARITIES), 2):
        pair = RARITIES[i:i+2]
        rows.append([
            InlineKeyboardButton(
                text=r,
                callback_data=f"itemedit:rarity:{case_id}:{item_id}:{r}",
            ) for r in pair
        ])
    rows.append([InlineKeyboardButton(
        text="↩️ Назад",
        callback_data=f"itemedit:menu:{case_id}:{item_id}",
    )])
    return InlineKeyboardMarkup(inline_keyboard=rows)


def edit_case_keyboard(case_id: int, is_active: bool) -> InlineKeyboardMarkup:
    toggle_label = "⏸ Деактивировать" if is_active else "▶️ Активировать"
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="✏️ Изменить имя", callback_data=f"editcase:name:{case_id}")],
        [InlineKeyboardButton(text="💰 Изменить цену", callback_data=f"editcase:price:{case_id}")],
        [InlineKeyboardButton(text="🖼 Изменить картинку", callback_data=f"editcase:image:{case_id}")],
        [InlineKeyboardButton(text="➕ Добавить предмет", callback_data=f"editcase:additem:{case_id}")],
        [InlineKeyboardButton(text=toggle_label, callback_data=f"editcase:toggle:{case_id}")],
        [InlineKeyboardButton(text="📋 Показать предметы", callback_data=f"editcase:showitems:{case_id}")],
        [InlineKeyboardButton(text="↩️ Назад", callback_data="editcase:back")],
    ])


def item_list_keyboard(case_id: int, items: list) -> InlineKeyboardMarkup:
    rows = []
    for it in items:
        label = f"{it.name} ({it.rarity}) — id {it.id}"
        rows.append([InlineKeyboardButton(
            text=label,
            callback_data=f"itemedit:menu:{case_id}:{it.id}",
        )])
    rows.append([InlineKeyboardButton(text="↩️ К кейсу", callback_data=f"editcase:back_to:{case_id}")])
    return InlineKeyboardMarkup(inline_keyboard=rows)


def item_menu_keyboard(case_id: int, item_id: int) -> InlineKeyboardMarkup:
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="✏️ Имя", callback_data=f"itemedit:name:{case_id}:{item_id}")],
        [InlineKeyboardButton(text="🎨 Редкость", callback_data=f"itemedit:rarity_menu:{case_id}:{item_id}")],
        [InlineKeyboardButton(text="⚖️ Вес", callback_data=f"itemedit:weight:{case_id}:{item_id}")],
        [InlineKeyboardButton(text="💰 Награда", callback_data=f"itemedit:point_value:{case_id}:{item_id}")],
        [InlineKeyboardButton(text="🖼 Картинка", callback_data=f"itemedit:image:{case_id}:{item_id}")],
        [InlineKeyboardButton(text="🗑 Удалить", callback_data=f"itemedit:delete_confirm:{case_id}:{item_id}")],
        [InlineKeyboardButton(text="↩️ К списку", callback_data=f"editcase:showitems:{case_id}")],
    ])


def item_delete_confirm_keyboard(case_id: int, item_id: int) -> InlineKeyboardMarkup:
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="🗑 Да, удалить", callback_data=f"itemedit:delete_yes:{case_id}:{item_id}")],
        [InlineKeyboardButton(text="↩️ Отмена", callback_data=f"itemedit:menu:{case_id}:{item_id}")],
    ])


def edit_tour_keyboard(tpl_id: int) -> InlineKeyboardMarkup:
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="🏅 top_n (победителей)", callback_data=f"edittour:top_n:{tpl_id}")],
        [InlineKeyboardButton(text="👁 display_limit (показ в топе)", callback_data=f"edittour:display_limit:{tpl_id}")],
        [InlineKeyboardButton(text="🎁 Награды по местам", callback_data=f"edittour:rewards:{tpl_id}")],
        [InlineKeyboardButton(text="🔁 Повтор", callback_data=f"edittour:toggle_recurring:{tpl_id}")],
        [InlineKeyboardButton(text="🏷 Призы (текст по местам)", callback_data=f"edittour:labels:{tpl_id}")],
        [InlineKeyboardButton(text="✂️ Макс. длина ника", callback_data=f"edittour:nicklen:{tpl_id}")],
    ])


def tour_rewards_keyboard() -> InlineKeyboardMarkup:
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="✅ Готово", callback_data="edittour:rewards:done")],
    ])

def activity_config_keyboard() -> InlineKeyboardMarkup:
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="💬 Очки за коммент", callback_data="actcfg:points_comment")],
        [InlineKeyboardButton(text="📊 Лимит комментов/день", callback_data="actcfg:daily_limit_comment")],
        [InlineKeyboardButton(text="⏱ Кулдаун комментов (сек)", callback_data="actcfg:comment_cooldown_seconds")],
        [InlineKeyboardButton(text="📏 Мин. длина коммента", callback_data="actcfg:min_comment_length")],
        [InlineKeyboardButton(text="🔁 Дубликаты (вкл/выкл)", callback_data="actcfg:block_duplicate_comments")],
        [InlineKeyboardButton(text="📢 Очки за подписку", callback_data="actcfg:points_subscription")],
        [InlineKeyboardButton(text="👥 Очки за реферала", callback_data="actcfg:points_referral")],
        [InlineKeyboardButton(text="🎯 Реферал: после действия (вкл/выкл)", callback_data="actcfg:referral_requires_action")],
    ])