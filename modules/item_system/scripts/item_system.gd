extends Node
class_name ItemSystem

## 物品系统
## 负责管理物品、商店、配方和强化相关的功能

# 信号
signal initialized(success: bool)  # 初始化完成信号
signal item_used(item: ItemInstance, target: Node)  # 物品使用信号
signal item_crafted(recipe_id: String, result: ItemInstance)  # 物品合成信号
signal item_enhanced(item: ItemInstance, success: bool)  # 物品强化信号

# 常量
const MODEL_TYPES_PATH = "res://modules/item_system/resource/"
const DATA_TABLES_PATH = "res://datatables/"

# 内部变量
var _data_manager: DataManager
var _logger = CoreSystem.logger
var _initialized: bool = false

# 数据缓存
var _items: Dictionary = {}  # 物品数据缓存
var _shops: Dictionary = {}  # 商店数据缓存
var _recipes: Dictionary = {}  # 配方数据缓存
var _enhancements: Dictionary = {}  # 强化数据缓存
var _abilities: Dictionary = {}  # 技能数据缓存

## 初始化
func initialize() -> void:
	if _initialized:
		return
		
	_logger.info("Initializing ItemSystem...")
	
	# 创建数据管理器
	_data_manager = DataManager.new()
	
	# 注册模型类型
	_register_model_types()
	
	# 加载数据表
	_load_data_tables()

## 注册模型类型
func _register_model_types() -> void:
	var model_types = {
		"items": load(MODEL_TYPES_PATH + "item_model_type.tres"),
		"shops": load(MODEL_TYPES_PATH + "shop_model_type.tres"),
		"recipes": load(MODEL_TYPES_PATH + "recipe_model_type.tres"),
		"enhancements": load(MODEL_TYPES_PATH + "enhancement_model_type.tres"),
		"abilities": load(MODEL_TYPES_PATH + "ability_model_type.tres")
	}
	
	for key in model_types:
		_data_manager.register_model_type(key, model_types[key])
		_logger.debug("Registered model type: %s" % key)

## 加载数据表
func _load_data_tables() -> void:
	var tables = {
		"items": "items.csv",
		"shops": "shops.csv",
		"recipes": "recipes.csv",
		"enhancements": "enhancements.csv",
		"abilities": "item_abilities.csv"
	}
	
	var load_count = 0
	var total_count = tables.size()
	
	# 加载每个数据表
	for key in tables:
		var path = DATA_TABLES_PATH + tables[key]
		_data_manager.load_data_async(key, path, 
			func(success: bool, data: Array):
				if success:
					match key:
						"items": _cache_items(data)
						"shops": _cache_shops(data)
						"recipes": _cache_recipes(data)
						"enhancements": _cache_enhancements(data)
						"abilities": _cache_abilities(data)
					load_count += 1
					
					# 检查是否所有数据都加载完成
					if load_count == total_count:
						_on_all_data_loaded()
				else:
					_logger.error("Failed to load %s data" % key)
					initialized.emit(false)
		)

## 数据加载完成回调
func _on_all_data_loaded() -> void:
	_initialized = true
	_logger.info("ItemSystem initialized successfully")
	initialized.emit(true)

## 缓存物品数据
func _cache_items(data: Array) -> void:
	for item in data:
		_items[item.id] = item
	_logger.debug("Cached %d items" % data.size())

## 缓存商店数据
func _cache_shops(data: Array) -> void:
	for shop in data:
		_shops[shop.id] = shop
	_logger.debug("Cached %d shops" % data.size())

## 缓存配方数据
func _cache_recipes(data: Array) -> void:
	for recipe in data:
		_recipes[recipe.id] = recipe
	_logger.debug("Cached %d recipes" % data.size())

## 缓存强化数据
func _cache_enhancements(data: Array) -> void:
	for enhancement in data:
		_enhancements[enhancement.id] = enhancement
	_logger.debug("Cached %d enhancements" % data.size())

## 缓存技能数据
func _cache_abilities(data: Array) -> void:
	for ability in data:
		_abilities[ability.id] = ability
	_logger.debug("Cached %d abilities" % data.size())

## 获取物品数据
func get_item_data(item_id: String) -> Dictionary:
	return _items.get(item_id, {})

## 获取商店数据
func get_shop_data(shop_id: String) -> Dictionary:
	return _shops.get(shop_id, {})

## 获取配方数据
func get_recipe_data(recipe_id: String) -> Dictionary:
	return _recipes.get(recipe_id, {})

## 获取强化数据
func get_enhancement_data(enhancement_id: String) -> Dictionary:
	return _enhancements.get(enhancement_id, {})

## 获取技能数据
func get_ability_data(ability_id: String) -> Dictionary:
	return _abilities.get(ability_id, {})

## 创建物品实例
func create_item_instance(item_id: String, quantity: int = 1) -> ItemInstance:
	var item_data = get_item_data(item_id)
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
func craft_item(recipe_id: String, inventory: Inventory) -> bool:
	var recipe = get_recipe_data(recipe_id)
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
func enhance_item(item: ItemInstance, inventory: Inventory) -> bool:
	if not item or item.enhancement_level >= 15:
		return false
		
	var enhancement = get_enhancement_data("ENHANCE_LEVEL_%d" % (item.enhancement_level + 1))
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
