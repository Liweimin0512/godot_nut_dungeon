extends AbilityEffect
class_name AttributeModifierEffect

## 属性修改器的技能效果包装

@export var modifiers : Array[AbilityAttributeModifier]
@export_storage var modify_multiplier: int = 1

func apply_effect(context: Dictionary = {}) -> void:
	_context.merge(context, true)
	var targets : Array = _get_targets()
	_context["targets"] = targets
	var _s = _context.get("source")
	if _s and _s is AbilityBuff:
		modify_multiplier = _s.value
	for target in targets:
		var ability_component: AbilityComponent = target.ability_component
		for modifier : AbilityAttributeModifier in modifiers:
			modifier.value *= modify_multiplier
			ability_component.apply_attribute_modifier(modifier)
			print("对目标应用属性修改器：{0}".format([modifier]))
	super(_context)

## 移除效果
func remove_effect(context: Dictionary = {}) -> void:
	if not context.is_empty():
		_context.merge(context, true)
	var targets : Array = _get_targets()
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
