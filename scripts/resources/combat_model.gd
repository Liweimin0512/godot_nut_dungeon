extends Resource
class_name CombatModel

## 战斗数据模型

## 最大回合数
@export var max_turn_count: int = 99
## 敌人models
@export var enemies : Array[CharacterModel]
## 是否自动开始
@export var is_auto : bool = true
## 是否实时
@export var is_real_time : bool = true

func _ready(config : Dictionary) -> void:
	var index := 0
	for key : String in config:
		if key.begins_with("enemy_"):
			_append_enemy(config["enemy_" + str(index + 1)])
			index += 1

func _append_enemy(enemy_id : StringName) -> void:
	if enemy_id.is_empty():
		enemies.append(null)
	else:
		var character : CharacterModel = DatatableManager.get_data_model("character", enemy_id)
		enemies.append(character)
