extends Node

## 合成系统管理器
## 负责管理合成配方和合成操作

# 信号
signal recipe_unlocked(recipe: RecipeData)
signal recipe_crafted(recipe: RecipeData, result: ItemInstance)
signal crafting_failed(recipe: RecipeData, reason: String)

# 内部变量
var _recipe_data_table: Dictionary = {}
var _unlocked_recipes: Array[int] = []
var _logger = CoreSystem.logger

func _ready() -> void:
	_load_recipe_data()

## 加载配方数据
func _load_recipe_data() -> void:
	var csv_path = "res://datatables/recipes.csv"
	var table = GDDataForge.load_csv(csv_path)
	
	for row in table:
		var recipe = RecipeData.new()
		recipe.id = int(row["id"])
		recipe.name = row["name"]
		recipe.name_zh = row["name_zh"]
		recipe.description = row["description"]
		recipe.description_zh = row["description_zh"]
		recipe.result_item = int(row["result_item"])
		recipe.result_amount = int(row["result_amount"])
		recipe.materials = row["materials"].split(",").map(func(x): return int(x))
		recipe.material_amounts = row["material_amounts"].split(",").map(func(x): return int(x))
		recipe.unlock_condition = row["unlock_condition"]
		
		_recipe_data_table[recipe.id] = recipe
		
		# 如果是默认解锁的配方
		if recipe.unlock_condition == "default":
			unlock_recipe(recipe.id)
			
		_logger.debug("Loaded recipe data: %s" % recipe.name)

## 解锁配方
func unlock_recipe(recipe_id: int) -> void:
	if not _recipe_data_table.has(recipe_id):
		_logger.error("Invalid recipe id: %d" % recipe_id)
		return
		
	if _unlocked_recipes.has(recipe_id):
		return
		
	_unlocked_recipes.append(recipe_id)
	recipe_unlocked.emit(_recipe_data_table[recipe_id])

## 尝试合成
func try_craft(recipe_id: int, inventory: InventoryComponent) -> bool:
	if not _recipe_data_table.has(recipe_id):
		_logger.error("Invalid recipe id: %d" % recipe_id)
		return false
		
	if not _unlocked_recipes.has(recipe_id):
		crafting_failed.emit(_recipe_data_table[recipe_id], "Recipe not unlocked")
		return false
		
	var recipe = _recipe_data_table[recipe_id]
	
	# 检查材料
	if not recipe.check_materials(inventory):
		crafting_failed.emit(recipe, "Not enough materials")
		return false
	
	# 检查背包空间
	var result_item = CoreSystem.item_manager.create_item(recipe.result_item, recipe.result_amount)
	if not inventory.has_space_for(result_item):
		crafting_failed.emit(recipe, "Not enough inventory space")
		return false
	
	# 消耗材料
	if not recipe.consume_materials(inventory):
		crafting_failed.emit(recipe, "Failed to consume materials")
		return false
	
	# 添加结果物品
	if not inventory.add_item(result_item):
		crafting_failed.emit(recipe, "Failed to add result item")
		return false
	
	recipe_crafted.emit(recipe, result_item)
	return true

## 获取配方数据
func get_recipe(recipe_id: int) -> RecipeData:
	return _recipe_data_table.get(recipe_id)

## 获取已解锁的配方
func get_unlocked_recipes() -> Array[RecipeData]:
	var recipes: Array[RecipeData] = []
	for id in _unlocked_recipes:
		recipes.append(_recipe_data_table[id])
	return recipes

## 检查配方是否已解锁
func is_recipe_unlocked(recipe_id: int) -> bool:
	return _unlocked_recipes.has(recipe_id)

## 获取可用的配方（有足够材料的已解锁配方）
func get_available_recipes(inventory: InventoryComponent) -> Array[RecipeData]:
	var recipes: Array[RecipeData] = []
	for id in _unlocked_recipes:
		var recipe = _recipe_data_table[id]
		if recipe.check_materials(inventory):
			recipes.append(recipe)
	return recipes
