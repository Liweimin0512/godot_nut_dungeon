extends Node
class_name AbilityComponent

## 技能组件

## 最大生命值
@export var max_health : float = 100
## 当前生命值
@export_storage var current_health : float = 100:
	set(value):
		current_health = value
		current_health_changed.emit(current_health)
## 攻击力
@export var attack_power : float = 10.0
## 防御力
@export var defense_power : float = 5
## 出手速度
@export var speed : float = 1
## 当前单位所有的技能消耗资源
@export var ability_resources : Array[AbilityResource]
## 当前单位所拥有的全部技能
@export var abilities : Array[Ability]
## 技能执行上下文
var context : Dictionary :
	set(value):
		context = value
		for effect in _get_all_effects():
			effect.update_context(context)

signal current_health_changed(value: float)
signal cast_finished(ability: Ability)

## 组件初始化
func initialization(caster: Node) -> void:
	context["caster"] = caster
	current_health = max_health
	for res : AbilityResource in ability_resources:
		res.initialization(self)
	for ability in abilities:
		ability.initialization(context)
		ability.cast_finished.connect(
			func() -> void:
				cast_finished.emit(ability)
		)

## 获取属性值
func get_attribute_value(atr_name : StringName) -> float:
	return get(atr_name)

#region 消耗资源相关

## 检查资源是否足够消耗
func has_enough_resources(res_name: StringName, cost: int) -> bool:
	if res_name.is_empty(): return true
	return get_resource_value(res_name) >= cost

## 获取资源数量
func get_resource_value(res_name: StringName) -> int:
	var res := get_resource(res_name)
	if res:
		return res.current_value
	return -1

## 获取资源
func get_resource(res_name: StringName) -> AbilityResource:
	for res : AbilityResource in ability_resources:
		if res.ability_resource_name == res_name:
			return res
	return null

## 消耗资源
func consume_resources(res_name: StringName, cost: int) -> void:
	var res := get_resource(res_name)
	if res:
		res.consume(cost)

#endregion

## 获取可用技能
func get_available_abilities() -> Array[Ability]:
	var available_abilities : Array[Ability] = abilities.filter(
		func(ability: Ability) -> bool:
			return _is_ability_available(ability)
	)
	return available_abilities

## 尝试释放技能
func try_cast_ability(ability: Ability, targets : Array) -> void:
	if not has_enough_resources(ability.cost_resource_name, ability.cost_resource_value):
		print("消耗不足，无法释放技能！")
		return
	if ability.is_cooldown:
		print("技能正在冷却！")
		return
	await get_tree().create_timer(0.5).timeout
	var caster : Node = context.caster
	consume_resources(ability.cost_resource_name, ability.cost_resource_value)
	var context : Dictionary = {} if targets.is_empty() else {
		"targets" : targets
	}
	print("ability: {0}释放技能：{1}".format([caster, ability]))
	for effect : AbilityEffect in ability.effects:
		effect.apply_effect(context)
	ability.current_cooldown = ability.cooldown

## 判断技能是否可用
func _is_ability_available(ability: Ability) -> bool:
	## 这个方法用来筛选哪些可用的主动技能
	return not ability.is_cooldown and not ability.is_auto_cast and has_enough_resources(ability.cost_resource_name, ability.cost_resource_value)

## 更新技能冷却计时，在回合开始前
func _update_ability_cooldown() -> void:
	for ability : Ability in abilities:
		if ability.is_cooldown:
			ability.current_cooldown -= 1

#region 触发时机回调函数

## 战斗开始
func on_combat_start() -> void:
	for res : AbilityResource in ability_resources:
		res.on_combat_start()
	for effect in _get_all_effects():
		if effect.has_method("on_combat_start"):
			effect.on_combat_start()

## 战斗结束
func on_combat_end() -> void:
	for res : AbilityResource in ability_resources:
		res.on_combat_end()
	for effect in _get_all_effects():
		if effect.has_method("on_combat_end"):
			effect.on_combat_end()

## 回合开始
func on_turn_start() -> void:
	# 回合开始时更新技能的冷却计时
	_update_ability_cooldown()
	for res : AbilityResource in ability_resources:
		res.on_turn_start()
	for effect in _get_all_effects():
		if effect.has_method("on_turn_start"):
			effect.on_turn_start()

## 回合结束
func on_turn_end() -> void:
	for res : AbilityResource in ability_resources:
		res.on_turn_end()
	for effect in _get_all_effects():
		if effect.has_method("on_turn_end"):
			effect.on_turn_end()

## 造成伤害
func on_hit() -> void:
	for res : AbilityResource in ability_resources:
		res.on_hit()
	for effect in _get_all_effects():
		if effect.has_method("on_hit"):
			effect.on_hit()

## 受到伤害
func on_hurt(source: Node, damage: float) -> void:
	for res : AbilityResource in ability_resources:
		res.on_hurt()
	for effect in _get_all_effects():
		if effect.has_method("on_hurt"):
			effect.on_hurt({
			"source": source,
			"damage": damage
		})

## 死亡
func on_die() -> void:
	for res : AbilityResource in ability_resources:
		res.on_die()
	for effect in _get_all_effects():
		if effect.has_method("on_die"):
			effect.on_die()
#endregion

func _get_all_effects() -> Array[AbilityEffect]:
	var effects : Array[AbilityEffect]
	for ability in abilities:
		effects += ability.effects
	return effects
