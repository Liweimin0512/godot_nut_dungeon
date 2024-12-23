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

signal current_health_changed(value: float)

## 当前单位所有的技能消耗资源
@export var ability_resources : Array[AbilityResource]
## 当前单位所拥有的全部技能
@export var abilities : Array[Ability]

## 组件初始化
func initialization() -> void:
	current_health = max_health
	for res : AbilityResource in ability_resources:
		res.initialization(self)
	for ability in abilities:
		ability.initialization()

## 获取属性值
func get_attribute_value(atr_name : StringName) -> float:
	return get(atr_name)

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
func on_hurt() -> void:
	for res : AbilityResource in ability_resources:
		res.on_hurt()
	for ability in abilities:
		ability.on_hurt()

## 死亡
func on_die() -> void:
	for res : AbilityResource in ability_resources:
		res.on_die()
	for ability in abilities:
		ability.on_die()
