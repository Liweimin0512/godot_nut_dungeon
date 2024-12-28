extends AbilityTriggerCondition
class_name AbilityTriggerConditionChance

## 概率条件判断

@export var chance: float = 1.0

func check(_context: Dictionary) -> bool:
    return randf() < chance