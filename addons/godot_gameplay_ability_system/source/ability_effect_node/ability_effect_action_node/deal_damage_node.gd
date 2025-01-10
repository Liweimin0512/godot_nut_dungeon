extends AbilityEffectActionNode
class_name DealDamageEffectNode

## 处理伤害

## 伤害倍数
@export var damage_multiplier: float = 1.0
## 伤害倍数数组
@export var damage_multiplier_array: Array[float] = []
## 伤害类型
@export var damage_type: AbilityDamage.DAMAGE_TYPE = AbilityDamage.DAMAGE_TYPE.PHYSICAL
## 是否为间接伤害
@export var is_indirect: bool = false
## 伤害附带效果
@export var effect: AbilityEffectNode = null

func _perform_action(context: Dictionary) -> STATUS:
	if context.get("ability").ability_name == "漩涡约束":
		pass
	var _damage_multiplier : float
	var repeat_index = context.get("repeat_index", null)
	if repeat_index != null:
		GASLogger.debug("DealDamageEffectNode repeat_index: %s" % [repeat_index])
		_damage_multiplier = damage_multiplier_array[repeat_index - 1]
	else:
		GASLogger.debug("DealDamageEffectNode damage_multiplier: %s" % [damage_multiplier])
		_damage_multiplier = damage_multiplier
	var caster : Node = context.get("caster")
	var target : Node = context.get("target")
	if not target:
		GASLogger.error("DealDamageEffectNode target is null")
		return STATUS.FAILURE
	var damage : AbilityDamage = AbilityDamage.new(
		caster, target, damage_type, is_indirect, effect)
	damage.apply_damage_modifier("percentage", _damage_multiplier - 1)
	await damage.apply_damage()
	return STATUS.SUCCESS

func _description_getter() -> String:
	var _type_name: String
	match damage_type:
		AbilityDamage.DAMAGE_TYPE.PHYSICAL:
			_type_name = "物理伤害"
		AbilityDamage.DAMAGE_TYPE.MAGICAL:
			_type_name = "魔法伤害"
		AbilityDamage.DAMAGE_TYPE.PURE:
			_type_name = "真实伤害"
		AbilityDamage.DAMAGE_TYPE.HEAL:
			_type_name = "治疗"
		_:
			_type_name = "伤害"
	if damage_multiplier_array.size() > 0:
		return "分别造成{0}%的{1}".format([",".join(damage_multiplier_array.map(func(x): return str(x * 100))), _type_name])
	else:
		return "造成{0}%的{1}".format([damage_multiplier * 100, _type_name])
