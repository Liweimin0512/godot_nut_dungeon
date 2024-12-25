extends AbilityEffect
class_name CounterAttackEffect

## 反击

@export var counter_chance: float = 0.3  # 反击的概率
@export var damage_multiplier: float = 0.6  # 反击造成的伤害倍数

func _init() -> void:
	effect_type = "counter_attack"
	target_type = "enemy"

func apply_effect(context: Dictionary = {}) -> void:
	if randf() > counter_chance: return
	var caster : Node = _context.caster
	var target : Node = _context.source # 伤害来源作为目标
	var ability_component : AbilityComponent = caster.get("ability_component")
	if ability_component:
		var damage = ability_component.attack_power * damage_multiplier
		if caster.has_method("hit"):
			caster.hit(target, damage)
			print("应用效果：{0}，对{1}造成{2}点反击伤害！".format([
				description, target, damage
			]))
		else:
			assert(false)
	super()

func on_hurt(context: Dictionary) -> void:
	_context.merge(context, true	)
	apply_effect()

func _description_getter() -> String:
	return "受到攻击时有{0}的几率造成反击，反击伤害倍数为：{1}".format([
		counter_chance, damage_multiplier
	])
