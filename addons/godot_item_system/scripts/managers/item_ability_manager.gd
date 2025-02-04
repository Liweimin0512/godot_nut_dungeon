extends Node

## 道具技能管理器
## 负责管理道具技能数据和创建道具技能实例

# 信号
signal ability_activated(ability_id: String, target: Node)
signal ability_ended(ability_id: String)

# 内部变量
var _ability_data_table: Dictionary = {}
var _logger = CoreSystem.logger

func _ready() -> void:
	_load_ability_data()

## 加载技能数据
func _load_ability_data() -> void:
	var csv_path = "res://datatables/item_abilities.csv"
	var table = GDDataForge.load_csv(csv_path)
	
	for row in table:
		var data = {
			"id": row["ID"],
			"name": row["name"],
			"name_zh": row["name_zh"],
			"description": row["description"],
			"description_zh": row["description_zh"],
			"ability_class": row["ability_class"],
			"cost_type": row["cost_type"],
			"cost_value": float(row["cost_value"]),
			"cooldown": float(row["cooldown"]),
			"target_type": row["target_type"],
			"effects": JSON.parse_string(row["effects"])
		}
		
		_ability_data_table[data["id"]] = data
		_logger.debug("Loaded ability data: %s" % data["name"])

## 创建技能实例
func create_ability(ability_id: String, item: ItemInstance) -> ItemAbility:
	if not _ability_data_table.has(ability_id):
		_logger.error("Invalid ability id: %s" % ability_id)
		return null
		
	var data = _ability_data_table[ability_id]
	var ability_class = load(data["ability_class"])
	if not ability_class:
		_logger.error("Failed to load ability class: %s" % data["ability_class"])
		return null
		
	var ability = ability_class.new()
	ability.initialize(item)
	
	# 连接信号
	ability.ability_activated.connect(
		func(): ability_activated.emit(ability_id, ability.owner)
	)
	ability.ability_ended.connect(
		func(): ability_ended.emit(ability_id)
	)
	
	return ability

## 获取技能数据
func get_ability_data(ability_id: String) -> Dictionary:
	return _ability_data_table.get(ability_id, {})
