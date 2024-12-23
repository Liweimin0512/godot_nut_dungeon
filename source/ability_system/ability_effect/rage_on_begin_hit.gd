extends AbilityEffect
class_name RageOnBeginHitEffect

## 受击时（前）概率获得怒气

@export var rage_chance: float = 0.3  # 获得怒气的概率
@export var rage_amount: int = 5  # 获得的怒气值

func _init() -> void:
	effect_type = "rage_on_being_hit"
	target_type = "self"

func apply_effect(character):
	if randf() < rage_chance:
		character.gain_rage(rage_amount)
