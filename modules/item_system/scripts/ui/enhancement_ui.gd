extends SceneComponent
class_name EnhancementUI

## 强化UI组件
## 显示和管理强化界面

# 导出变量
@export var inventory: InventoryComponent
@export var equipment_container: GridContainer
@export var material_container: GridContainer
@export var selected_slot: ItemSlotUI
@export var success_rate_label: Label
@export var cost_label: Label
@export var material_label: Label
@export var enhance_button: Button
@export var item_tip_scene: PackedScene

# 内部变量
var _selected_equipment: ItemInstance
var _item_tip: ItemTipUI
var _logger = CoreSystem.logger

func _ready() -> void:
	super._ready()
	
	if not inventory:
		_logger.error("EnhancementUI: No inventory component assigned")
		return
	
	# 创建物品提示UI
	_item_tip = item_tip_scene.instantiate()
	add_child(_item_tip)
	_item_tip.hide()
	
	# 连接信号
	enhance_button.pressed.connect(_on_enhance_pressed)
	inventory.slots_changed.connect(_update_display)
	CoreSystem.enhancement_manager.enhancement_succeeded.connect(_on_enhancement_succeeded)
	CoreSystem.enhancement_manager.enhancement_failed.connect(_on_enhancement_failed)
	
	# 初始化显示
	_update_display()

## 更新显示
func _update_display() -> void:
	_update_equipment_list()
	_update_material_list()
	_update_enhancement_info()

## 更新装备列表
func _update_equipment_list() -> void:
	# 清除现有物品槽
	for child in equipment_container.get_children():
		child.queue_free()
	
	# 添加可强化的装备
	for item in inventory.get_all_items():
		if item.item_data.type == ItemData.ItemType.EQUIPMENT:
			var slot = ItemSlotUI.new()
			slot.item_instance = item
			equipment_container.add_child(slot)
			
			# 连接信号
			slot.item_clicked.connect(_on_equipment_clicked.bind(slot))

## 更新材料列表
func _update_material_list() -> void:
	# 清除现有物品槽
	for child in material_container.get_children():
		child.queue_free()
	
	# 添加材料
	for item in inventory.get_all_items():
		if item.item_data.type == ItemData.ItemType.MATERIAL:
			var slot = ItemSlotUI.new()
			slot.item_instance = item
			material_container.add_child(slot)
			
			# 连接信号
			slot.item_clicked.connect(_on_material_clicked.bind(slot))

## 更新强化信息
func _update_enhancement_info() -> void:
	if not _selected_equipment:
		success_rate_label.text = "成功率: --"
		cost_label.text = "费用: --"
		material_label.text = "材料: --"
		enhance_button.disabled = true
		selected_slot.item_instance = null
		return
	
	var next_level = _selected_equipment.enhancement_level + 1
	
	# 更新选中装备显示
	selected_slot.item_instance = _selected_equipment
	
	# 更新成功率
	var success_rate = CoreSystem.enhancement_manager.get_success_rate(next_level)
	success_rate_label.text = "成功率: %d%%" % success_rate
	
	# 更新费用
	var cost = CoreSystem.enhancement_manager.calculate_enhancement_cost(_selected_equipment)
	cost_label.text = "费用: %d 金币" % cost
	
	# 更新材料需求
	var required = CoreSystem.enhancement_manager.get_required_materials(next_level)
	var current = _get_material_count()
	material_label.text = "材料: %d/%d" % [current, required]
	
	# 更新按钮状态
	enhance_button.disabled = not CoreSystem.enhancement_manager.can_enhance(_selected_equipment) or \
							inventory.money < cost or \
							current < required

## 获取材料数量
func _get_material_count() -> int:
	var count = 0
	for item in inventory.get_all_items():
		if item.item_data.type == ItemData.ItemType.MATERIAL:
			count += item.quantity
	return count

## 处理装备点击
func _on_equipment_clicked(button: int, slot: ItemSlotUI) -> void:
	if button == MOUSE_BUTTON_LEFT:
		_selected_equipment = slot.item_instance
		_update_enhancement_info()
		
		# 显示物品提示
		_item_tip.item_instance = slot.item_instance
		_item_tip.set_tip_position(get_global_mouse_position())
		_item_tip.show()

## 处理材料点击
func _on_material_clicked(button: int, slot: ItemSlotUI) -> void:
	if button == MOUSE_BUTTON_LEFT:
		# 显示物品提示
		_item_tip.item_instance = slot.item_instance
		_item_tip.set_tip_position(get_global_mouse_position())
		_item_tip.show()

## 处理强化按钮点击
func _on_enhance_pressed() -> void:
	if _selected_equipment:
		CoreSystem.enhancement_manager.try_enhance(_selected_equipment, inventory)

## 处理强化成功
func _on_enhancement_succeeded(item: ItemInstance, level: int) -> void:
	_logger.info("Enhancement succeeded! %s reached level %d" % [item.item_data.name, level])
	_update_display()

## 处理强化失败
func _on_enhancement_failed(item: ItemInstance, level: int) -> void:
	_logger.warning("Enhancement failed! %s failed to reach level %d" % [item.item_data.name, level])
	_update_display()

## 处理输入
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if _item_tip.visible:
			_item_tip.set_tip_position(get_global_mouse_position())
	elif event is InputEventMouseButton:
		if not event.pressed and _item_tip.visible:
			_item_tip.hide()
