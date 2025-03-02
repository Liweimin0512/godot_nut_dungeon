extends Resource
class_name CombatAction

## 战斗行动类，用于描述一个战斗行动的所有相关信息

enum ActionType {
	MELEE,      ## 近战攻击
	RANGED,     ## 远程攻击
}

var actor: Node2D          					## 行动者
var targets: Array[Node] = []    			## 目标
var ability: TurnBasedSkillAbility 			## 技能
var action_type: ActionType        			## 行动类型


func _init(
		p_actor: Node2D, 
		p_targets: Array[Node], 
		p_ability = null,
		) -> void:
	actor = p_actor
	targets = p_targets
	ability = p_ability
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
	
func is_self() -> bool:
	return false

func is_ally() -> bool:
	return false


func _to_string() -> String:
	return "CombatAction { actor: %s, targets: %s, ability: %s }" % [actor, targets, ability]
