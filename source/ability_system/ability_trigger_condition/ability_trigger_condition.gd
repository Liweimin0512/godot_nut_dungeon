extends Resource
class_name AbilityTriggerCondition

## 技能触发条件

## 条件判断,在派生类中实现
func check(context: Dictionary) -> bool:
	return false
