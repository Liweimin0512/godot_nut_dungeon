extends AbilityTriggerCondition
class_name AbilityTriggerConditionAbilityName

## 概率条件判断

@export var ability_names: PackedStringArray

func check(context: Dictionary) -> bool:
	var ability_name : String = context.ability.ability_name
	if ability_names.is_empty() : return true
	if not ability_name.is_empty() and ability_name in ability_names:
		print("条件判断：技能名称{0}符合条件".format([ability_name]))
		return true
	print("条件判断：技能名称{0}不符合条件".format([ability_name]))
	return false
