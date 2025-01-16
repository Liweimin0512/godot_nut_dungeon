extends SkillAbility
class_name TurnBasedSkillAbility

## 回合制技能

func _ready(config: Dictionary) -> void:
	for i in range(0, config.ability_costs.size(), 2):
		var cost_id : StringName = config.ability_costs[i]
		var cost_amount : int = int(config.ability_costs[i + 1])
		var _cost : AbilityResourceCost = AbilityResourceCost.new(cost_id, cost_amount)
		ability_costs.append(_cost)

## 回合开始前, 更新技能冷却
func on_pre_turn_start(_data: Dictionary = {}) -> void:
	_update_cooldown(1)
