extends Resource
class_name AbilityEffectModifier

## 技能效果修改器

@export var condition : AbilityTriggerCondition

## 应用
func apply(context: Dictionary = {}) -> void:
	pass

## 移除
func remove(context: Dictionary = {}) -> void:
	pass
