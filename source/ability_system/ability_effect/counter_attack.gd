extends DealDamageEffect
class_name CounterAttackEffect

## 反击，继承自伤害效果，增加触发条件和概率判断

@export var counter_chance: float = 0.3  # 反击的概率

func _init() -> void:
	effect_type = "counter_attack"
	target_type = "enemy"

func on_hurt(context: Dictionary) -> void:
	if randf() > counter_chance: return
	_context.merge(context, true	)
	_context["targets"] = [context.source]
	apply_effect()

func _description_getter() -> String:
	return "受到攻击时有{0}的几率造成反击，反击伤害倍数为：{1}".format([
		counter_chance, damage_multiplier
	])
