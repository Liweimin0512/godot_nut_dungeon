extends Resource
class_name AbilityEffect

## 技能效果

## 效果类型，用于区分不同效果 
@export var effect_type: StringName
## 目标类型，如self, ally, enemy
@export var target_type: StringName

## 应用效果的基础方法，由子类实现具体的逻辑
func apply_effect(character):
	pass
