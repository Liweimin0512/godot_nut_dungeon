extends AbilityEffect
class_name DealDamageEffect

## 伤害倍数
@export var damage_multiplier: float = 1.0

func _init() -> void:
	target_type = "enemy"
	effect_type = "deal_damage"
	target_amount = 1

func apply_effect(context: Dictionary = {}) -> void:
	_context.merge(context, true)
	var caster : Node = _context.caster
	var ability_component : AbilityComponent = caster.get("ability_component")
	var attack : float = ability_component.get_attribute_value("攻击力")
	var damage = attack * damage_multiplier
	var targets : Array = _context.get("targets")
	for target in targets:
		if caster.has_method("hit"):
			print("应用效果：{0}，{3}对目标 {1} 造成 {2} 点伤害".format([
				description, target, damage, caster
			]))
			caster.hit(target, damage)
	super()

func _description_getter() -> String:
	return "对目标造成{0}%的伤害".format([damage_multiplier * 100])
