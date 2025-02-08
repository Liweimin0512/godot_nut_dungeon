extends Resource
class_name CombatModel

## 战斗数据模型

## 最大回合数
@export var max_turn_count: int = 99
## 敌人models
@export var enemy_data : Array[CharacterModel]
## 是否自动开始
@export var is_auto : bool = true
## 是否实时
@export var is_real_time : bool = true

## 从数据字典初始化
## [param data] 数据字典
func _init_from_data(data : Dictionary) -> void:
	var index := 0
	for key : String in data:
		if key.begins_with("enemy_"):
			_append_enemy(data["enemy_" + str(index + 1)])
			index += 1

## 添加敌人
## [param enemy_id] 敌人ID
func _append_enemy(enemy_id : StringName) -> void:
	if enemy_id.is_empty():
		enemy_data.append(null)
	else:
		var character : CharacterModel = DataManager.get_data_model("character", enemy_id)
		enemy_data.append(character)
