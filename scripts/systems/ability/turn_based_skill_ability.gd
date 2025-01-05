extends SkillAbility
class_name TurnBasedSkillAbility

## 回合制技能

## 技能施法位置
@export var casting_position : AbilityDefinition.CASTING_POSITION = AbilityDefinition.CASTING_POSITION.NONE

## 回合开始前, 更新技能冷却
func on_pre_turn_start(_data: Dictionary = {}) -> void:
	_update_cooldown()
