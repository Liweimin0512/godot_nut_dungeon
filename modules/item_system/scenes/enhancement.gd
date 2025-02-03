extends SceneComponent
class_name EnhancementUI

## 强化UI组件
## 显示和管理物品强化界面

# 导出变量
@export var inventory: InventoryComponent
@export var inventory_items_container: GridContainer
@export var selected_slot: ItemSlot
@export var material_container: GridContainer
@export var success_rate_label: Label
@export var cost_label: Label
@export var material_label: Label
@export var item_tip_scene: PackedScene

# 内部变量
var _item_tip: ItemTip
var _selected_item: ItemInstance
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
	inventory.slots_changed.connect(_update_inventory_items)
	
	# 初始化显示
	_update_inventory_items()

## 更新背包物品
func _update_inventory_items() -> void:
	# 清空容器
	for child in inventory_items_container.get_children():
		child.queue_free()
	
	# 添加背包物品
	for item in inventory.items:
		if not item:
			continue
			
		var slot = ItemSlot.new()
		slot.item_instance = item
		inventory_items_container.add_child(slot)
		
		# 连接信号
		slot.item_clicked.connect(_on_inventory_item_clicked.bind(item))
		slot.item_selected.connect(_on_inventory_item_selected.bind(item))

## 更新强化信息显示
func _update_enhancement_info() -> void:
	if not _selected_item:
		selected_slot.item_instance = null
		success_rate_label.text = "成功率: 0%"
		cost_label.text = "费用: 0 金币"
		material_label.text = "材料: 0/0"
		return
	
	# 获取强化信息
	var enhancement = CoreSystem.item_system.get_enhancement_data(_selected_item)
	if not enhancement:
		return
	
	# 更新显示
	selected_slot.item_instance = _selected_item
	success_rate_label.text = "成功率: " + str(enhancement.success_rate) + "%"
	cost_label.text = "费用: " + str(enhancement.cost) + " 金币"
	material_label.text = "材料: " + str(inventory.get_item_count(enhancement.material_id)) + "/" + str(enhancement.material_amount)
	
	# 更新材料显示
	for child in material_container.get_children():
		child.queue_free()
	
	var material = CoreSystem.item_system.create_item_instance(enhancement.material_id, enhancement.material_amount)
	var slot = ItemSlot.new()
	slot.item_instance = material
	material_container.add_child(slot)

## 背包物品点击
func _on_inventory_item_clicked(item: ItemInstance) -> void:
	_selected_item = item
	_update_enhancement_info()

## 背包物品选中
func _on_inventory_item_selected(slot: ItemSlot, item: ItemInstance) -> void:
	if slot and item:
		_item_tip.show_tip(item)
	else:
		_item_tip.hide_tip()

## 强化按钮点击
func _on_enhance_button_pressed() -> void:
	if not _selected_item:
		return
	
	# 获取强化信息
	var enhancement = CoreSystem.item_system.get_enhancement_data(_selected_item)
	if not enhancement:
		return
	
	# 检查材料是否足够
	if not inventory.has_item(enhancement.material_id, enhancement.material_amount):
		return
	
	# 检查金钱是否足够
	if inventory.money < enhancement.cost:
		return
	
	# 扣除材料和金钱
	inventory.remove_item(enhancement.material_id, enhancement.material_amount)
	inventory.remove_money(enhancement.cost)
	
	# 尝试强化
	var success = CoreSystem.item_system.try_enhance_item(_selected_item)
	if success:
		# 更新显示
		_update_enhancement_info()
	else:
		# 强化失败
		if enhancement.destroy_on_fail:
			inventory.remove_item(_selected_item.id, 1)
			_selected_item = null
			_update_enhancement_info()
