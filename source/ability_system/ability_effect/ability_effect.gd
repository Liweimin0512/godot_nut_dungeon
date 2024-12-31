extends Resource
class_name AbilityEffect

## 技能效果，一个技能可能包括不只一个效果，且这些效果还可以包含其他效果。形成树状结构
## 技能是瞬时的，持续一段时间的技能效果需要包装成buff

## 目标类型，如self, ally, enemy
## 未指定目标类型则从技能上下文中获取目标
@export var target_type: StringName
## 目标数量
@export var target_amount: int = 1
## 效果触发条件
@export var trigger_conditions: Array[AbilityTriggerCondition]
## 技能效果修改器
@export var effect_modifiers: Array[AbilityEffectModifier]
## 后置效果
@export var post_effects: Array[AbilityEffect]
## 技能效果描述
var description : String: get = _description_getter
## 释放子弹
@export var _bullet_scene : PackedScene

## 应用技能效果后触发
signal applied
## 移除技能效果后触发
signal removed

## 应用效果
func apply_effect(context: Dictionary) -> void:
	if not _check_conditions(context): return
	var targets : Array = _get_targets(context)
	for target in targets:
		var ct : Dictionary = context
		ct["targets"] = [target]
		var bullet := _create_bullect(context.get("caster").owner, target.owner)
		if bullet and bullet.cast_time + bullet.wait_time > 0:
			await target.get_tree().create_timer(bullet.cast_time + bullet.wait_time).timeout
		_apply(ct)
	applied.emit()

func _apply(context: Dictionary) -> void:
	# 父类的这个方法应该在子类方法执行之后调用
	for effect in post_effects:
		effect.apply_effect(context)

## 移除效果
func remove_effect(context: Dictionary) -> void:
	var targets : Array = _get_targets(context)
	for target in targets:
		_remove(context)
	removed.emit()

func _remove(context: Dictionary) -> void:
	for effect in post_effects:
		effect.remove_effect(context)

## 创建子弹
func _create_bullect(caster : Node2D, target: Node2D) -> Bullet:
	if not _bullet_scene: return null
	var bullet : Bullet = _bullet_scene.instantiate()
	bullet.target_point = target.global_position
	caster.add_child(bullet)
	return bullet

## 判断条件
func _check_conditions(context: Dictionary) -> bool:
	for condition in trigger_conditions:
		var ok := condition.check(context)
		if not ok:
			return false
	return true

## 获取目标
func _get_targets(context: Dictionary) -> Array:
	var targets := []  # 使用 := 进行类型推断和变量初始化
	var target_pool := []  # 统一的数组来存储目标池
	# 根据目标类型确定目标池
	if target_type == "self":
		return [context.caster]
	elif target_type == "ally":
		target_pool = context.allies.duplicate()
	elif target_type == "enemy":
		target_pool = context.enemies.duplicate()
	# 从目标池中随机选择目标
	for i in range(target_amount):
		if target_pool.is_empty():
			break  # 如果目标池为空，退出循环
		var target : Node = target_pool.pick_random()
		targets.append(target)
		target_pool.erase(target)  # 从目标池中移除已选目标
	if target_type.is_empty():
		# 如果没有配置目标类型，则继承自技能或上一级技能效果
		targets = context.get("targets", [])
	return targets

func _description_getter() -> String:
	return ""
