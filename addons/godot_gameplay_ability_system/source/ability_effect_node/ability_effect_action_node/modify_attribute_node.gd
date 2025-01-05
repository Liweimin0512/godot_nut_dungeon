extends AbilityEffectActionNode
class_name ModifyAttributeNode

## 属性修改器的技能效果包装

@export var modifiers : Array[AbilityAttributeModifier]
@export_storage var modify_multiplier: int = 1

func _perform_action(context: Dictionary = {}) -> STATUS:
	var target = context.get("target")
	if not target:
		GASLogger.error("ModifyAttributeNode target is null")
		return STATUS.FAILURE
	var _s = context.get("source")
	if _s and _s is BuffAbility:
		modify_multiplier = _s.value
	var ability_component: AbilityComponent = target.ability_component
	for modifier : AbilityAttributeModifier in modifiers:
		modifier.value *= modify_multiplier
		ability_component.apply_attribute_modifier(modifier)
		GASLogger.info("对目标应用属性修改器：{0}".format([modifier]))
	return STATUS.SUCCESS

## 移除效果
func _revoke_action(context: Dictionary = {}) -> STATUS:
	var target = context.get("target")
	if not target:
		GASLogger.error("ModifyAttributeNode target is null")
		return STATUS.FAILURE
	var ability_component: AbilityComponent = target.ability_component
	for modifier : AbilityAttributeModifier in modifiers:
		ability_component.remove_attribute_modifier(modifier)
		GASLogger.info("移除效果：对目标应用属性修改器：{0}".format([modifier]))
	return STATUS.SUCCESS

func _description_getter() -> String:
	var s : String = ""
	for modifier in modifiers:
		s += modifier.to_string()
	return s
