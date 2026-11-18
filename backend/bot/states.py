from aiogram.fsm.state import State, StatesGroup


class NewCaseStates(StatesGroup):
    name = State()
    price = State()
    items = State()
    confirm = State()
    add_item_image = State()


class EditCaseStates(StatesGroup):
    menu = State()
    edit_name = State()
    edit_price = State()
    add_item_name = State()
    add_item_rarity = State()
    add_item_weight = State()
    add_item_quality = State()
    add_item_point_value = State()
    # редактирование предмета
    item_edit_name = State()
    item_edit_rarity = State()
    item_edit_weight = State()
    item_edit_quality = State()
    item_edit_point_value = State()
    add_item_image = State()

class EditTourStates(StatesGroup):
    edit_top_n = State()
    edit_display_limit = State()
    edit_rewards_step = State()
    edit_nicklen = State()
    edit_labels = State()

class ActivityConfigStates(StatesGroup):
    edit_value = State()

class BroadcastStates(StatesGroup):
    waiting_content = State()
    confirm = State()

class ImageUploadStates(StatesGroup):
    waiting_photo = State()

class ActivityConfigStates(StatesGroup):
    edit_value = State()
    edit_quality_weights = State()
    edit_quality_mults = State()
    edit_stattrak = State()

class RulesStates(StatesGroup):
    edit_text = State()

class WipeBalanceStates(StatesGroup):
    waiting_new_value = State()
    confirm = State()