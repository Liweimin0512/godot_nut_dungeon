extends Resource
class_name AbilityEffect

## 技能效果，一个技能可能包括不只一个效果，且这些效果还可以包含其他效果。形成树状结构
## 技能是瞬时的，持续一段时间的技能效果需要包装成buff

## 效果类型，用于区分不同效果 
#@export var effect_type: StringName
## 目标类型，如self, ally, enemy
@export var target_type: StringName
## 目标数量
@export var target_amount: int = 1
## 后置效果
@export var effects: Array[AbilityEffect]
## 技能效果描述
var description : String: get = _description_getter
## 技能上下文
var _context : Dictionary

## 应用技能效果后触发
signal applied
## 移除技能效果后触发
signal removed

## 初始化效果类
func initialization(context: Dictionary) -> void:
	_context = context

## 应用效果
func apply_effect(context: Dictionary = {}) -> void:
	# 父类的这个方法应该在子类方法执行之后调用
	for effect in effects:
		effect.apply_effect(context)
	applied.emit()

## 移除效果
func remove_effect(context: Dictionary = {}) -> void:
	for effect in effects:
		effect.remove_effect(context)
	removed.emit()

## 更新技能上下文
func update_context(context) -> void:
	_context.merge(context, true	)

## 获取目标
func _get_targets() -> Array:
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

func _description_getter() -> String:
	return ""
