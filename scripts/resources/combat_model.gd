extends Resource
class_name CombatModel

## 战斗数据模型

## 最大回合数
@export var max_turn_count: int = 99
## 敌人models
@export var enemy_data : Array[StringName]
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
			var enemy_id : StringName = data["enemy_" + str(index + 1)]
			enemy_data.append(enemy_id)
			index += 1
