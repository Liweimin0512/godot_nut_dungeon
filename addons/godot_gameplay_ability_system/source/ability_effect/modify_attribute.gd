extends AbilityEffect
class_name ModifyAttribute

## 属性修改器的技能效果包装

@export var modifiers : Array[AbilityAttributeModifier]
@export_storage var modify_multiplier: int = 1

func _apply(context: Dictionary = {}) -> void:
	var targets : Array = _get_targets(context)
	var _s = context.get("source")
	if _s and _s is BuffAbility:
		modify_multiplier = _s.value
	for target in targets:
		var ability_component: AbilityComponent = target.ability_component
		for modifier : AbilityAttributeModifier in modifiers:
			modifier.value *= modify_multiplier
			ability_component.apply_attribute_modifier(modifier)
			print("对目标应用属性修改器：{0}".format([modifier]))
	super(context)

## 移除效果
func _remove(context: Dictionary = {}) -> void:
	var targets : Array = _get_targets(context)
	for target in targets:
		var ability_component: AbilityComponent = target.ability_component
		for modifier : AbilityAttributeModifier in modifiers:
			ability_component.remove_attribute_modifier(modifier)
			print("移除效果：对目标应用属性修改器：{0}".format([modifier]))
	super(context)

func _description_getter() -> String:
	var s : String = ""
	for modifier in modifiers:
		s += modifier.to_string()
	return s
