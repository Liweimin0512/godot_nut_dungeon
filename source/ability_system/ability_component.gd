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
## 技能组件所有者，这里是CombatComponent
var caster : Node
## 所有盟友
var allies : Array
## 所有敌人
var enemies : Array

signal current_health_changed(value: float)


## 组件初始化
func initialization(caster: Node) -> void:
	self.caster = caster
	current_health = max_health
	for res : AbilityResource in ability_resources:
		res.initialization(self)
	for ability in abilities:
		ability.initialization(caster, {
			"allies": allies,
			"enemies": enemies
		})

## 获取属性值
func get_attribute_value(atr_name : StringName) -> float:
	return get(atr_name)

#region 消耗资源相关

## 检查资源是否足够消耗
func has_enough_resources(res_name: StringName, cost: int) -> bool:
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
	return abilities.filter(
		func(ability: Ability) -> bool:
			return ability.is_available
	)

## 尝试释放技能
func try_cast_ability(ability: Ability) -> void:
	if not ability.has_enough_resources:
		print("消耗不足，无法释放技能！")
		return
	if ability.is_cooldown:
		print("技能正在冷却！")
		return
	await get_tree().create_timer(0.5).timeout
	ability.cast()

#region 触发时机回调函数

## 战斗开始
func on_combat_start() -> void:
	for res : AbilityResource in ability_resources:
		res.on_combat_start()
	for ability in abilities:
		ability.on_combat_start()

## 战斗结束
func on_combat_end() -> void:
	for res : AbilityResource in ability_resources:
		res.on_combat_end()
	for ability in abilities:
		ability.on_combat_end()

## 回合开始
func on_turn_start() -> void:
	for res : AbilityResource in ability_resources:
		res.on_turn_start()
	for ability in abilities:
		ability.on_turn_start()

## 回合结束
func on_turn_end() -> void:
	for res : AbilityResource in ability_resources:
		res.on_turn_end()
	for ability in abilities:
		ability.on_turn_end()

## 造成伤害
func on_hit() -> void:
	for res : AbilityResource in ability_resources:
		res.on_hit()
	for ability in abilities:
		ability.on_hit()

## 受到伤害
func on_hurt(source: Node, damage: float) -> void:
	for res : AbilityResource in ability_resources:
		res.on_hurt()
	for ability in abilities:
		ability.on_hurt({
			"source": source,
			"damage": damage
		})

## 死亡
func on_die() -> void:
	for res : AbilityResource in ability_resources:
		res.on_die()
	for ability in abilities:
		ability.on_die()
#endregion
