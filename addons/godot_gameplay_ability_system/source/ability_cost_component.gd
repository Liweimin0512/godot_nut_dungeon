extends Node
class_name AbilityCostComponent

## 技能消耗组件

## 消耗技能
func cost_ability(ability: Ability, context: Dictionary) -> bool:
	if not ability.ability_cost.can_cost(context):
		return false
	ability.ability_cost.cost(context)
	return true

## 是否能消耗技能
func can_cost_ability(ability: Ability, context: Dictionary) -> bool:
	return ability.ability_cost.can_cost(context)
