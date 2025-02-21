extends AbilityRestriction
class_name PositionRestriction

## 位置限制器

## 有效位置
@export var valid_positions : Array = [1, 2, 3, 4]
## 目标位置
@export var target_positions: Array = [1, 2, 3, 4]

func _init(config: Dictionary = {}) -> void:
	valid_positions = config.get("valid_positions", [1, 2, 3, 4])
	target_positions = config.get("target_positions", [1, 2, 3, 4])

func can_use(context: Dictionary) -> bool:
	var position = context.get("position", -1)
	return _can_use_at_position(position)

## 判断能否在指定位置使用
func _can_use_at_position(position: int) -> bool:
	return valid_positions.is_empty() or position in valid_positions
