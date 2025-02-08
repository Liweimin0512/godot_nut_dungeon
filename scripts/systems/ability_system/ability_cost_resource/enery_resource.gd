extends AbilityResource
class_name EneryResource

## 能量，适合敏捷系英雄单位
## 随时间快速恢复

## 每次回复的值
@export var per_regain: int

func _init() -> void:
	ability_resource_id = "energy"
	ability_resource_name = "能量值"

func _initialization(_attribute_component: AbilityAttributeComponent) -> void:
	ability_resource_id = "energy"
	ability_resource_name = "能量值"
	max_value = 100
	current_value = 100

## 每回合自动恢复
func on_turn_start(_context: Dictionary) -> void:
	var amount = max_value * 0.1
	restore(amount)
