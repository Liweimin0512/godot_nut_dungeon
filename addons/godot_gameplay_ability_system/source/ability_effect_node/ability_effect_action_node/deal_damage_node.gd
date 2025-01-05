extends AbilityEffectActionNode
class_name DealDamageEffectNode

## 处理伤害

## 伤害倍数
@export var damage_multiplier: float = 1.0
## 伤害类型
@export var damage_type: AbilityDamage.DAMAGE_TYPE = AbilityDamage.DAMAGE_TYPE.PHYSICAL
## 是否为间接伤害
@export var is_indirect: bool = false
## 伤害附带效果
@export var effect: AbilityEffectNode = null

func _perform_action(context: Dictionary) -> STATUS:
	var caster : Node = context.get("caster")
	var target : Node = context.get("target")
	if not target:
		GASLogger.error("DealDamageEffectNode target is null")
		return STATUS.FAILURE
	var damage : AbilityDamage = AbilityDamage.new(
		caster, target, damage_type, is_indirect, effect)
	damage.apply_damage_modifier("percentage", damage_multiplier - 1)
	damage.apply_damage()
	return STATUS.SUCCESS

func _description_getter() -> String:
	return "对目标造成{0}%的伤害".format([damage_multiplier * 100])
