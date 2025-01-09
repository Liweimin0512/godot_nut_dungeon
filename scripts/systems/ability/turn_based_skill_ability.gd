extends SkillAbility
class_name TurnBasedSkillAbility

## 回合制技能


## 回合开始前, 更新技能冷却
func on_pre_turn_start(_data: Dictionary = {}) -> void:
	_update_cooldown(1)
