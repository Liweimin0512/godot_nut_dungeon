extends AbilityEffect
class_name PercentageBoostEffect

## 百分比提升属性

@export var boost_percentage: float = 0.1  # 增加的百分比
@export var attribute: StringName  # 属性类型，如attack, defense

func _init() -> void:
	effect_type = "percentage_boost"
	target_type = "self"

func apply_effect(context: Dictionary = {}) -> void:
	for target in _get_targets():
		var ability_component: AbilityComponent = target.ability_component
		var boost_amount = ability_component.get_attribute_value(attribute) * boost_percentage
		if attribute == "attack_power":
			ability_component.attack_power += boost_amount
		elif attribute == "defense_power":
			ability_component.defense_power += boost_amount
		print("对目标{0}应用效果{1}，获得{2}点{3}属性提升".format([
			target, description, boost_amount, attribute
		]))
	super()

func _description_getter() -> String:
	return "提升目标{0}%的{1}属性".format([
		boost_percentage * 100, attribute
		])
