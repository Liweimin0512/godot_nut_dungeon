extends AbilityTriggerCondition
class_name AbilityTriggerConditionAbilityName

## 概率条件判断

@export var ability_names: PackedStringArray

func check(context: Dictionary) -> bool:
	var ability_name : String = context.ability_name
	if ability_names.is_empty() : return true
	if not ability_name.is_empty() and ability_name in ability_names:
		return true
	return false
