extends AbilityEffect
class_name CounterAttackEffect

## 反击

@export var counter_chance: float = 0.3  # 反击的概率
@export var damage_multiplier: float = 0.6  # 反击造成的伤害倍数

func _init() -> void:
	effect_type = "counter_attack"
	target_type = "enemy"

func apply_effect(context: Dictionary):
	if randf() > counter_chance: return
	var caster : Node = context.caster
	var target : Node = context.source # 伤害来源作为目标
	var ability_component : AbilityComponent = caster.get("ability_component")
	if ability_component:
		var damage = ability_component.attack * damage_multiplier
		if caster.has_method("hit"):
			caster.hit(target, damage)
		else:
			assert(false)

func on_hurt(context: Dictionary) -> void:
	_context.merge(context, true	)
	apply_effect(_context)
