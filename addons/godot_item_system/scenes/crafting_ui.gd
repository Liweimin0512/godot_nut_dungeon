extends SceneComponent
class_name CraftingUI

## 合成UI组件
## 显示和管理合成界面

# 导出变量
@export var inventory: InventoryComponent
@export var recipe_list: ItemList
@export var material_container: VBoxContainer
@export var result_slot: ItemSlotUI
@export var craft_button: Button
@export var item_tip_scene: PackedScene

# 内部变量
var _current_recipe: RecipeData
var _item_tip: ItemTipUI
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
	recipe_list.item_selected.connect(_on_recipe_selected)
	craft_button.pressed.connect(_on_craft_pressed)
	inventory.slots_changed.connect(_update_recipe_list)
	CoreSystem.crafting_manager.recipe_unlocked.connect(_on_recipe_unlocked)
	CoreSystem.crafting_manager.recipe_crafted.connect(_on_recipe_crafted)
	CoreSystem.crafting_manager.crafting_failed.connect(_on_crafting_failed)
	
	# 初始化显示
	_update_recipe_list()

## 更新配方列表
func _update_recipe_list() -> void:
	recipe_list.clear()
	
	var available_recipes = CoreSystem.crafting_manager.get_available_recipes(inventory)
	var unlocked_recipes = CoreSystem.crafting_manager.get_unlocked_recipes()
	
	# 先添加可用的配方
	for recipe in available_recipes:
		recipe_list.add_item(recipe.get_localized_name(), null, true)
		recipe_list.set_item_metadata(recipe_list.get_item_count() - 1, recipe)
	
	# 再添加不可用的配方
	for recipe in unlocked_recipes:
		if not available_recipes.has(recipe):
			recipe_list.add_item(recipe.get_localized_name(), null, false)
			recipe_list.set_item_metadata(recipe_list.get_item_count() - 1, recipe)

## 更新材料显示
func _update_material_display() -> void:
	# 清除现有材料显示
	for child in material_container.get_children():
		child.queue_free()
	
	if not _current_recipe:
		result_slot.item_instance = null
		craft_button.disabled = true
		return
	
	# 显示结果物品
	var result_item = CoreSystem.item_manager.create_item(
		_current_recipe.result_item,
		_current_recipe.result_amount
	)
	result_slot.item_instance = result_item
	
	# 显示所需材料
	for i in range(_current_recipe.materials.size()):
		var material_id = _current_recipe.materials[i]
		var required_amount = _current_recipe.material_amounts[i]
		
		# 创建材料显示行
		var hbox = HBoxContainer.new()
		material_container.add_child(hbox)
		
		# 材料图标和名称
		var material_item = CoreSystem.item_manager.create_item(material_id)
		var icon = TextureRect.new()
		icon.texture = material_item.item_data.icon
		hbox.add_child(icon)
		
		var name_label = Label.new()
		name_label.text = material_item.item_data.get_localized_name()
		hbox.add_child(name_label)
		
		# 材料数量
		var amount_label = Label.new()
		var current_amount = _get_material_amount(material_id)
		amount_label.text = "%d/%d" % [current_amount, required_amount]
		if current_amount < required_amount:
			amount_label.modulate = Color.RED
		hbox.add_child(amount_label)
	
	# 更新合成按钮状态
	craft_button.disabled = not _current_recipe.check_materials(inventory)

## 获取材料数量
func _get_material_amount(material_id: int) -> int:
	var amount = 0
	for item in inventory.get_all_items():
		if item.item_data.id == material_id:
			amount += item.quantity
	return amount

## 处理配方选择
func _on_recipe_selected(index: int) -> void:
	_current_recipe = recipe_list.get_item_metadata(index)
	_update_material_display()

## 处理合成按钮点击
func _on_craft_pressed() -> void:
	if _current_recipe:
		CoreSystem.crafting_manager.try_craft(_current_recipe.id, inventory)

## 处理配方解锁
func _on_recipe_unlocked(_recipe: RecipeData) -> void:
	_update_recipe_list()

## 处理合成成功
func _on_recipe_crafted(_recipe: RecipeData, _result: ItemInstance) -> void:
	_update_recipe_list()
	_update_material_display()

## 处理合成失败
func _on_crafting_failed(_recipe: RecipeData, reason: String) -> void:
	_logger.warning("Crafting failed: %s" % reason)
	# TODO: 显示错误提示

## 处理输入
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if _item_tip.visible:
			_item_tip.set_tip_position(get_global_mouse_position())
	elif event is InputEventMouseButton:
		if not event.pressed and _item_tip.visible:
			_item_tip.hide()
