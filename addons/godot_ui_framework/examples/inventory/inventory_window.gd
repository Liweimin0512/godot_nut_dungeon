extends Control

@onready var grid_container: GridContainer = %GridContainer
@onready var close_button: Button = %CloseButton
@onready var ui_component: UISceneComponent = %UISceneComponent

const GRID_SIZE = 5 * 4  # 5行4列的背包格子

var _slots: Array[Control] = []

func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	ui_component.scene_opened.connect(_on_scene_opened)
	ui_component.scene_closed.connect(_on_scene_closed)

## 初始化背包格子
func _init_inventory_slots() -> void:
	var slot_data_list = []
	for i in range(GRID_SIZE):
		slot_data_list.append({"slot_index": i})
	
	_slots = UIManager.widget_manager.create_widgets(&"inventory_slot", grid_container, slot_data_list)
	for slot in _slots:
		slot.item_clicked.connect(_on_slot_clicked)

## 初始化测试物品
func _init_test_items() -> void:
	# 这里只是演示用，实际项目中应该从数据管理器获取数据
	var test_items = [
		{"slot": 0, "icon": preload("res://icon.svg"), "count": 1, "name": "测试物品1"},
		{"slot": 1, "icon": preload("res://icon.svg"), "count": 5, "name": "测试物品2"},
		{"slot": 4, "icon": preload("res://icon.svg"), "count": 10, "name": "测试物品3"},
	]
	
	for item in test_items:
		if item.slot < _slots.size():
			_slots[item.slot].refresh_item(item)

## 清理背包格子
func _clear_inventory_slots() -> void:
	for slot in _slots:
		slot.item_clicked.disconnect(_on_slot_clicked)
	UIManager.widget_manager.recycle_widgets(_slots)
	_slots.clear()

## 当物品格子被点击
func _on_slot_clicked(slot_index: int) -> void:
	var slot = _slots[slot_index]
	if not slot.item_data.is_empty():
		print("点击了物品：", slot.item_data.name)

## 当关闭按钮被点击
func _on_close_button_pressed() -> void:
	UIManager.close_scene(self)

## 当场景被打开
func _on_scene_opened(_scene: Control) -> void:
	_init_inventory_slots()
	_init_test_items()

## 当场景被关闭
func _on_scene_closed(_scene: Control) -> void:
	_clear_inventory_slots()
