extends RefCounted
class_name CombatAction

## 战斗行动类，用于描述一个战斗行动的所有相关信息

enum ActionType {
	MELEE,      ## 近战攻击
	RANGED,     ## 远程攻击
	SELF,       ## 自身技能
	ALLY,       ## 友方技能
}

var actor: Node2D                  ## 行动者
var targets: Array[Node2D] = []    ## 目标数组
var ability: TurnBasedSkillAbility ## 技能
var action_type: ActionType        ## 行动类型
var duration: float = 0.3          ## 动作持续时间

func _init(
		p_actor: Node2D, 
		p_targets: Array[Node2D], 
		p_ability = null
		) -> void:
	actor = p_actor
	targets = p_targets
	ability = p_ability
	_determine_action_type()

## 确定行动类型
func _determine_action_type() -> void:
	if not ability:
		action_type = ActionType.MELEE
		return
		
	match ability.target_range:
		TurnBasedSkillAbility.TARGET_RANGE.SELF:
			action_type = ActionType.SELF
		TurnBasedSkillAbility.TARGET_RANGE.SINGLE_ALLY, TurnBasedSkillAbility.TARGET_RANGE.ALL_ALLY:
			action_type = ActionType.ALLY
		_:
			action_type = ActionType.MELEE if ability.is_melee else ActionType.RANGED

## 获取字符串形式的行动类型
func get_type_string() -> String:
	return ActionType.keys()[action_type]

## 是否是近战行动
func is_melee() -> bool:
	return action_type == ActionType.MELEE

## 是否是远程行动
func is_ranged() -> bool:
	return action_type == ActionType.RANGED

## 是否是自身行动
func is_self() -> bool:
	return action_type == ActionType.SELF

## 是否是友方行动
func is_ally() -> bool:
	return action_type == ActionType.ALLY
