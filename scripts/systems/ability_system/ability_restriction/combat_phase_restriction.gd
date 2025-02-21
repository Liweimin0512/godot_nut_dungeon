extends AbilityRestriction
class_name CombatPhaseRestriction

## 可以在什么战斗阶段使用

var allowed_phases : Array[String]

func can_use(context: Dictionary) -> bool:
	var current_phase = context.get("combat_phase", "")
	var can_use = current_phase in allowed_phases
	if not can_use:
		can_use_reason = "Combat phase is not allowed."
	return can_use
