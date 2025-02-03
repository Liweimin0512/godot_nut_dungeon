extends MarginContainer
class_name InventoryUI

## 背包UI组件
## 显示和管理背包界面

# 导出变量
@export var inventory: InventoryComponent
@export var slots_container: GridContainer

# 内部变量
var _item_tip: ItemTipUI
var _dragging_slot: int = -1
var _logger = CoreSystem.logger

func _ready() -> void:	
	if not inventory:
		_logger.error("InventoryUI: No inventory component assigned")
		return
	
	# 创建物品提示UI
	_item_tip = item_tip_scene.instantiate()
	add_child(_item_tip)
	_item_tip.hide()
	
	# 连接信号
	inventory.slots_changed.connect(_on_slots_changed)
	inventory.money_changed.connect(_on_money_changed)
	
	# 初始化显示
	_create_slots()
	_update_money_display()

## 创建物品槽
func _create_slots() -> void:
	for i in range(inventory.slots_count):
		var slot = ItemSlotUI.new()
		slot.slot_index = i
		slots_container.add_child(slot)
		
		# 连接槽位信号
		slot.item_clicked.connect(_on_slot_clicked)
		slot.item_double_clicked.connect(_on_slot_double_clicked)
		slot.item_drag_started.connect(_on_slot_drag_started)
		slot.item_dropped.connect(_on_slot_dropped)
		
		# 设置初始物品
		slot.item_instance = inventory.get_item(i)

## 更新所有槽位显示
func _on_slots_changed() -> void:
	for slot in slots_container.get_children():
		if slot is ItemSlotUI:
			slot.item_instance = inventory.get_item(slot.slot_index)

## 更新金钱显示
func _on_money_changed(new_amount: int) -> void:
	money_label.text = str(new_amount) + " 金币"

## 处理槽位点击
func _on_slot_clicked(slot: int, button: int) -> void:
	var item = inventory.get_item(slot)
	if not item:
		return
		
	match button:
		MOUSE_BUTTON_LEFT:
			# 显示物品提示
			_item_tip.item_instance = item
			_item_tip.set_tip_position(get_global_mouse_position())
			_item_tip.show()
		MOUSE_BUTTON_RIGHT:
			# 使用物品
			if item.item_data.is_consumable():
				inventory.use_item(slot)

## 处理槽位双击
func _on_slot_double_clicked(slot: int) -> void:
	var item = inventory.get_item(slot)
	if item and item.item_data.is_consumable():
		inventory.use_item(slot)

## 处理开始拖动
func _on_slot_drag_started(slot: int) -> void:
	_dragging_slot = slot
	_item_tip.hide()

## 处理物品放下
func _on_slot_dropped(from_slot: int, to_slot: int) -> void:
	if from_slot != _dragging_slot:
		return
		
	inventory.swap_items(from_slot, to_slot)
	_dragging_slot = -1

## 处理输入
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if _dragging_slot == -1 and _item_tip.visible:
			_item_tip.set_tip_position(get_global_mouse_position())
	elif event is InputEventMouseButton:
		if not event.pressed and _item_tip.visible:
			_item_tip.hide()
