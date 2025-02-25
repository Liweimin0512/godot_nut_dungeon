extends Resource
class_name CombatAction

## 战斗行动类，用于描述一个战斗行动的所有相关信息

enum ActionType {
	MELEE,      ## 近战攻击
	RANGED,     ## 远程攻击
	SELF,       ## 自身技能
	ALLY,       ## 友方技能
}

var actor: Node2D          					## 行动者
var targets: Array[Node2D] = []:    				## 目标
	set(value):
		targets = value
		target_changed.emit()
var ability: TurnBasedSkillAbility: 		## 技能
	set(value):
		ability = value
		CombatSystem.action_ability_selected.push([self])
		ability_changed.emit()
var action_type: ActionType        			## 行动类型

var start_duration: float = 0.1
var execute_duration: float = 0.5
var end_duration: float = 0.2

signal ability_changed
signal target_changed

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
	action_type = _determine_action_type()


## 确定行动类型
func _determine_action_type() -> ActionType:
	if not ability:
		return ActionType.MELEE
	return ActionType.MELEE if ability.is_melee else ActionType.RANGED


## 是否是有效的行动
func is_valid() -> bool:
	return actor != null and ability != null


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
