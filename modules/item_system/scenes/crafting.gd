extends SceneComponent
class_name CraftingUI

## 合成UI组件
## 显示和管理物品合成界面

# 导出变量
@export var inventory: InventoryComponent
@export var recipe_items_container: GridContainer
@export var inventory_items_container: GridContainer
@export var material_items_container: GridContainer
@export var result_slot: ItemSlot
@export var money_label: Label
@export var item_tip_scene: PackedScene

# 内部变量
var _item_tip: ItemTip
var _selected_recipe: RecipeData
var _logger = CoreSystem.logger

func _ready() -> void:
	super._ready()
	
	if not inventory:
		_logger.error("CraftingUI: No inventory component assigned")
		return
	
	# 创建物品提示UI
	_item_tip = item_tip_scene.instantiate()
	add_child(_item_tip)
	_item_tip.hide()
	
	# 连接信号
	inventory.money_changed.connect(_update_money_display)
	
	# 初始化显示
	_update_recipe_items()
	_update_inventory_items()
	_update_money_display(inventory.money)

## 更新配方列表
func _update_recipe_items() -> void:
	# 清空容器
	for child in recipe_items_container.get_children():
		child.queue_free()
	
	# 添加配方物品
	var recipes = CoreSystem.item_system.get_all_recipes()
	for recipe in recipes:
		var slot = ItemSlot.new()
		slot.item_instance = recipe.result
		recipe_items_container.add_child(slot)
		
		# 连接信号
		slot.item_clicked.connect(_on_recipe_clicked.bind(recipe))
		slot.item_selected.connect(_on_recipe_selected.bind(recipe))

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

## 更新材料显示
func _update_material_display() -> void:
	# 清空容器
	for child in material_items_container.get_children():
		child.queue_free()
	
	if not _selected_recipe:
		result_slot.item_instance = null
		return
	
	# 显示所需材料
	for material in _selected_recipe.materials:
		var slot = ItemSlot.new()
		slot.item_instance = material
		material_items_container.add_child(slot)
	
	# 显示合成结果
	result_slot.item_instance = _selected_recipe.result

## 更新金钱显示
func _update_money_display(amount: int) -> void:
	money_label.text = str(amount) + " 金币"

## 配方点击
func _on_recipe_clicked(recipe: RecipeData) -> void:
	_selected_recipe = recipe
	_update_material_display()

## 配方选中
func _on_recipe_selected(slot: ItemSlot, recipe: RecipeData) -> void:
	if slot and recipe:
		_item_tip.show_tip(recipe.result)
	else:
		_item_tip.hide_tip()

## 背包物品点击
func _on_inventory_item_clicked(item: ItemInstance) -> void:
	pass # 可以实现拖放功能

## 背包物品选中
func _on_inventory_item_selected(slot: ItemSlot, item: ItemInstance) -> void:
	if slot and item:
		_item_tip.show_tip(item)
	else:
		_item_tip.hide_tip()

## 合成按钮点击
func _on_craft_button_pressed() -> void:
	if not _selected_recipe:
		return
		
	# 检查材料是否足够
	for material in _selected_recipe.materials:
		if not inventory.has_item(material.id, material.amount):
			return
	
	# 检查金钱是否足够
	if inventory.money < _selected_recipe.cost:
		return
	
	# 扣除材料和金钱
	for material in _selected_recipe.materials:
		inventory.remove_item(material.id, material.amount)
	inventory.remove_money(_selected_recipe.cost)
	
	# 添加合成结果
	inventory.add_item(_selected_recipe.result.id, _selected_recipe.result.amount)
	
	# 更新显示
	_update_inventory_items()
	_update_material_display()
