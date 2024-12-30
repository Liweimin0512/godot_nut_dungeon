extends AbilityEffect
class_name DealDamageEffect

## 处理伤害

## 伤害倍数
@export var damage_multiplier: float = 1.0
## 伤害类型
@export var damage_type: int = AbilityDamage.DamageType.PHYSICAL

func _apply(context: Dictionary = {}) -> void:
	var caster : Node = context.caster
	var ability_component : AbilityComponent = caster.get("ability_component")
	var targets : Array = _get_targets(context)
	for target in targets:
		var damage : AbilityDamage = AbilityDamage.new(
			caster, target, damage_type)
		damage.apply_damage_modifier("percentage", damage_multiplier - 1)
		if caster.has_method("hit"):
			print("应用效果：{0}，{3}对目标 {1} 造成 {2} 点伤害".format([
				description, target, damage, caster
			]))
			caster.hit(target, damage)
	super(context)

func _description_getter() -> String:
	return "对目标造成{0}%的伤害".format([damage_multiplier * 100])
