extends AbilityTriggerCondition
class_name AbilityTriggerConditionChance

## 概率条件判断

@export var chance: float = 1.0

func check(_context: Dictionary) -> bool:
	var rand_value: float = randf()
	print("条件判断：当前概率{0} 所需概率{1} {2}".format([rand_value, chance, "通过" if rand_value <= chance else "不通过！"]))
	return rand_value <= chance
