extends Resource
class_name AbilityEffectModifier

## 技能效果修改器

@export var condition : AbilityTriggerCondition

## 应用
func apply(_context: Dictionary = {}) -> void:
	pass

## 移除
func remove(_context: Dictionary = {}) -> void:
	pass
