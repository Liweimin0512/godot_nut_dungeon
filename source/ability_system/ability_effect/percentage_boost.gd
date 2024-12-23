extends AbilityEffect
class_name PercentageBoostEffect

## 百分比提升属性

@export var boost_percentage: float = 0.1  # 增加的百分比
@export var attribute: StringName  # 属性类型，如attack, defense

func _init() -> void:
	effect_type = "percentage_boost"
	target_type = "self"

func apply_effect(character):
	var boost_amount = character.get_attribute(attribute) * boost_percentage
	if attribute == "attack":
		character.attack += boost_amount
	elif attribute == "defense":
		character.defense += boost_amount
	# 可以根据需要添加更多属性
