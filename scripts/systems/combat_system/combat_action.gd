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

var start_duration: float = 0.1
var execute_duration: float = 0.5
var end_duration: float = 0.2

func _init(
		p_actor: Node2D, 
		p_targets: Array[Node2D], 
		p_ability = null,
		p_start_duration = 0.1,
		p_execute_duration = 0.5,
		p_end_duration = 0.2
		) -> void:
	actor = p_actor
	targets = p_targets
	ability = p_ability
	start_duration = p_start_duration
	execute_duration = p_execute_duration
	end_duration = p_end_duration
	action_type = _determine_action_type(actor, targets, ability)

## 确定行动类型
func _determine_action_type(p_actor: Node2D, 
		p_targets: Array[Node2D], p_ability: TurnBasedSkillAbility) -> ActionType:
	var _action_type : ActionType
	if not p_ability:
		_action_type = ActionType.MELEE
		return _action_type
		
	match p_ability.target_range:
		TurnBasedSkillAbility.TARGET_RANGE.SELF:
			_action_type = ActionType.SELF
		TurnBasedSkillAbility.TARGET_RANGE.SINGLE_ALLY, TurnBasedSkillAbility.TARGET_RANGE.ALL_ALLY:
			if p_targets.size() == 1 and p_targets[0] == p_actor:
				_action_type = ActionType.SELF
			else:
				_action_type = ActionType.ALLY
		_:
			_action_type = ActionType.MELEE if p_ability.is_melee else ActionType.RANGED
	return _action_type

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
