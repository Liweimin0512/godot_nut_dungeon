extends Resource
class_name AbilityEffect

## 技能效果

## 效果类型，用于区分不同效果 
@export var effect_type: StringName
## 目标类型，如self, ally, enemy
@export var target_type: StringName
## 目标数量
@export var target_amount: int = 1
## 技能上下文
var _context : Dictionary

## 初始化效果类
func initialization(context: Dictionary) -> void:
	_context = context

## 应用效果的基础方法，由子类实现具体的逻辑
func apply_effect(context: Dictionary):
	pass

## 获取目标
func _get_targets() -> Array[Node]:
	var targets := []  # 使用 := 进行类型推断和变量初始化
	var target_pool := []  # 统一的数组来存储目标池
	# 根据目标类型确定目标池
	if target_type == "self":
		return [_context.caster]
	elif target_type == "ally":
		target_pool = _context.allies.duplicate()
	elif target_type == "enemy":
		target_pool = _context.enemies.duplicate()
	# 从目标池中随机选择目标
	for i in range(target_amount):
		if target_pool.is_empty():
			break  # 如果目标池为空，退出循环
		var target : Node = target_pool.pick_random()
		targets.append(target)
		target_pool.erase(target)  # 从目标池中移除已选目标
	return targets

#region 触发时机回调函数

## 战斗开始
func on_combat_start() -> void:
	pass

## 战斗结束
func on_combat_end() -> void:
	pass

## 回合开始
func on_turn_start() -> void:
	pass

## 回合结束
func on_turn_end() -> void:
	pass

## 造成伤害
func on_hit() -> void:
	pass

## 受到伤害
func on_hurt(context: Dictionary) -> void:
	pass

## 死亡
func on_die() -> void:
	pass

#endregion
