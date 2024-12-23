extends AbilityEffect
class_name CounterAttackEffect

## 反击

@export var counter_chance: float = 0.3  # 反击的概率
@export var damage_multiplier: float = 0.6  # 反击造成的伤害倍数

func _init() -> void:
	effect_type = "counter_attack"
	target_type = "enemy"

func apply_effect(character):
	if randf() < counter_chance:
		var damage = character.attack * damage_multiplier
		character.attack_target(damage)
