extends AbilityEffect
class_name DealDamageEffect

## 伤害倍数
@export var damage_multiplier: float = 1.0

func _init() -> void:
	target_type = "enemy"
	effect_type = "deal_damage"

func apply_effect(character):
	var damage = character.attack * damage_multiplier
	character.take_damage(damage)
