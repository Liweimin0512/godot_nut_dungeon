extends Node

## 物品系统
## 负责管理物品、商店、配方和强化相关的功能

# 信号
## 初始化完成信号
signal initialized(success: bool)
## 物品使用信号
signal item_used(item: ItemInstance, target: Node)
## 物品合成信号
signal item_crafted(recipe_id: String, result: ItemInstance)
## 物品强化信号
signal item_enhanced(item: ItemInstance, success: bool)  

# 内部变量
var _logger : CoreSystem.Logger = CoreSystem.logger
## 已经初始化
var _initialized: bool = false
var _model_types : Array[ModelType] = [
	preload("res://addons/godot_item_system/resource/enhancement_model_type.tres"),
	preload("res://addons/godot_item_system/resource/item_model_type.tres"),
	preload("res://addons/godot_item_system/resource/recipe_model_type.tres"),
	preload("res://addons/godot_item_system/resource/shop_model_type.tres"),
]

## 初始化
func initialize(model_types: Array[ModelType] = [], completed_callable: Callable = Callable()) -> void:
	if _initialized:
		return
		
	_logger.info("Initializing ItemSystem...")
	if not model_types.is_empty():
		_model_types = model_types
	# 注册模型类型
	_register_model_types(completed_callable)

## 注册模型类型
func _register_model_types(completed_callable: Callable) -> void:
	DataManager.load_models(_model_types, _on_all_data_loaded.bind(completed_callable), _on_load_progress)
	_logger.debug("Load Model Types......")

## 创建物品实例
func create_item_instance(item_id: String, quantity: int = 1) -> ItemInstance:
	var item_data : ItemData = DataManager.get_data_model("item", item_id)
	if item_data.is_empty():
		_logger.error("Invalid item id: %s" % item_id)
		return null
		
	var instance = ItemInstance.new()
	instance.item_data = item_data
	instance.quantity = quantity
	return instance

## 使用物品
func use_item(item: ItemInstance, target: Node) -> bool:
	if not item:
		return false
		
	var success = item.use(target)
	if success:
		item_used.emit(item, target)
		
	return success

## 合成物品
func craft_item(recipe_id: String, inventory: InventoryComponent) -> bool:
	var recipe = DataManager.get_data_model("recipe", recipe_id)
	if recipe.is_empty():
		return false
	
	# 检查材料
	var materials = recipe.materials.split(",")
	var amounts = recipe.material_amounts.split(",")
	for i in range(materials.size()):
		var material_id = materials[i]
		var amount = int(amounts[i])
		if not inventory.has_item(material_id, amount):
			return false
	
	# 消耗材料
	for i in range(materials.size()):
		var material_id = materials[i]
		var amount = int(amounts[i])
		inventory.remove_item(material_id, amount)
	
	# 创建产物
	var result = create_item_instance(recipe.result_item, recipe.result_amount)
	if result:
		inventory.add_item(result)
		item_crafted.emit(recipe_id, result)
		return true
		
	return false

## 强化物品
func enhance_item(item: ItemInstance, inventory: InventoryComponent) -> bool:
	if not item or item.enhancement_level >= 15:
		return false
	
	var enhancement : Dictionary = DataManager.get_table_item("enhancement", "ENHANCE_LEVEL_%d" % (item.enhancement_level + 1))
	if enhancement.is_empty():
		return false
		
	# 检查材料
	if not inventory.has_item(enhancement.material_type, enhancement.material_amount):
		return false
		
	# 消耗材料
	inventory.remove_item(enhancement.material_type, enhancement.material_amount)
	
	# 执行强化
	var success = randf() * 100 <= enhancement.success_rate
	if success:
		item.enhancement_level += 1
	elif enhancement.protection_required:
		item.enhancement_level = 0
		
	item_enhanced.emit(item, success)
	return true

## 加载进度回调
func _on_load_progress(current: int, total: int) -> void:
	_logger.info("加载数据表完成，第{0}个，总共{1}个".format([current, total]))

## 数据加载完成回调
func _on_all_data_loaded(result: Array[String], completed_callable : Callable) -> void:
	for r in result:
		_logger.info("ItemSystem initialized successfully: %s" %r)
	if completed_callable.is_valid():
		completed_callable.call(result)
	_initialized = true
	initialized.emit(true)
