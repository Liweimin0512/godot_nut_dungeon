extends AbilityRestriction
class_name CastPositionRestriction

## 可施法位置配置
@export var valid_cast_positions: Array[int] = []  # 可以施法的位置

func _init(config : Dictionary = {}) -> void:
	var poss : Array = config.get("valid_positions", [])
	for pos in poss:
		valid_cast_positions.append(pos)

func can_execute(context: Dictionary) -> bool:
	var caster = context.get("caster", null)
	if not caster:
		return false

	var component := CombatSystem.get_combat_component(caster)
	var caster_position = component.combat_point
	if caster_position < 0:
		return false
		
	# 检查施法者位置是否合法
	return caster_position in valid_cast_positions
