extends Resource
class_name AbilityResource

## 技能消耗的资源，比如魔法值、怒气值、能量，设置是生命值

## 资源名
@export var ability_resource_name : StringName
## 当前值
@export_storage var current_value: int:
	set(value):
		current_value = value
		current_value_changed.emit(value)
## 最大值
@export var max_value: int:
	set(value):
		max_value = value
## 所对应的属性名称
@export var attribute_name : StringName
## 是否为空的
var is_empty : bool:
	get:
		return current_value == 0
## 是否为满的
var is_full : bool:
	get:
		return current_value == max_value

## 当前值改变时发射
signal current_value_changed

## ability_component的initialization
func initialization(ability_component: AbilityComponent) -> void:
	if not attribute_name.is_empty():
		var atr_value : int = ability_component.get_attribute_value(attribute_name)
		if atr_value:
			max_value = atr_value
			current_value = max_value

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
func on_hurt() -> void:
	pass

## 死亡
func on_die() -> void:
	pass

## 消耗
func consume(amount: int) -> bool:
	if current_value >= amount:
		current_value -= amount
		return true
	return false
	
## 恢复
func restore(amount: int) -> void:
	current_value += amount
	current_value = min(current_value, max_value)
