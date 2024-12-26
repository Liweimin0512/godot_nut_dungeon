extends AbilityEffect
class_name AttributeModifierEffect

## 属性修改器的技能效果包装

@export var modifiers : Array[AbilityAttributeModifier]

func apply_effect(context: Dictionary = {}) -> void:
	for target in _get_targets():
		var ability_component: AbilityComponent = target.ability_component
		for modifier : AbilityAttributeModifier in modifiers:
			ability_component.apply_attribute_modifier(modifier)
			print("对目标应用属性修改器：{0}".format([modifier]))
	super()

func _description_getter() -> String:
	var s : String = ""
	for modifier in modifiers:
		s += modifier.to_string()
	return s
