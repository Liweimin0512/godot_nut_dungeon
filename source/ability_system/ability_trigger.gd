extends Resource
class_name AbilityTrigger

## 技能触发器，用于触发技能效果

## 技能触发器类型
@export var trigger_type : AbilityDefinition.TRIGGER_TYPE

## 技能触发条件集合
@export var trigger_conditions : Array[AbilityTriggerCondition]

## 检查触发条件
func check(context: Dictionary) -> bool:
    for condition : AbilityTriggerCondition in trigger_conditions:
        if not condition.check(context):
            return false
    return true