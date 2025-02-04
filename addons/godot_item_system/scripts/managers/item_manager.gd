extends Node

## 道具管理器
## 负责管理所有道具数据和实例的创建

# 信号
signal item_created(item_instance: ItemInstance)
signal item_destroyed(item_instance: ItemInstance)

# 内部变量
var _item_data_table: Dictionary = {}
var _logger = CoreSystem.logger

func _ready() -> void:
	_load_item_data()

## 加载道具数据
func _load_item_data() -> void:
	var csv_path = "res://datatables/items.csv"
	var table = GDDataForge.load_csv(csv_path)
	
	for row in table:
		var item_data = ItemData.new()
		item_data.id = int(row["id"])
		item_data.name = row["name"]
		item_data.name_zh = row["name_zh"]
		item_data.description = row["description"]
		item_data.description_zh = row["description_zh"]
		item_data.icon = load(row["icon"]) if row["icon"] else null
		item_data.type = ItemData.ItemType[row["type"].to_upper()]
		item_data.rarity = int(row["rarity"]) - 1
		item_data.stack_size = int(row["stack_size"])
		item_data.price = int(row["price"])
		item_data.ability_id = row["ability_id"]
		item_data.effects = JSON.parse_string(row["effects"])
		
		_item_data_table[item_data.id] = item_data
		_logger.debug("Loaded item data: %s" % item_data.name)

## 创建道具实例
func create_item(item_id: int, quantity: int = 1) -> ItemInstance:
	if not _item_data_table.has(item_id):
		_logger.error("Failed to create item: invalid item id %d" % item_id)
		return null
		
	var instance = ItemInstance.new()
	instance.item_data = _item_data_table[item_id]
	instance.quantity = quantity
	
	item_created.emit(instance)
	return instance

## 销毁道具实例
func destroy_item(item: ItemInstance) -> void:
	if item:
		item_destroyed.emit(item)

## 获取道具数据
func get_item_data(item_id: int) -> ItemData:
	return _item_data_table.get(item_id)

## 获取所有道具数据
func get_all_item_data() -> Array:
	return _item_data_table.values()

## 获取指定类型的道具数据
func get_items_by_type(type: ItemData.ItemType) -> Array:
	var items = []
	for item in _item_data_table.values():
		if item.type == type:
			items.append(item)
	return items

## 获取指定稀有度的道具数据
func get_items_by_rarity(rarity: ItemData.ItemRarity) -> Array:
	var items = []
	for item in _item_data_table.values():
		if item.rarity == rarity:
			items.append(item)
	return items
