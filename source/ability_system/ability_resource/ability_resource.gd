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
## 对应属性
var _attribute : AbilityAttribute

## 当前值改变时发射
signal current_value_changed(value : int)

## ability_component的initialization
func initialization(ability_component: AbilityComponent) -> void:
	if not attribute_name.is_empty():
		_attribute = ability_component.get_attribute(attribute_name)
		max_value = round(_attribute.attribute_value)
		current_value = max_value
		_attribute.attribute_value_changed.connect(
			func(value: int) -> void:
				max_value = value
				current_value = max_value
		)

## 消耗
func consume(amount: int) -> bool:
	if current_value >= amount:
		current_value -= amount
		print("技能资源消耗：{0} 消耗 {1} 点，当前值： {2} / {3} ".format([
			ability_resource_name, amount, current_value, max_value
		]))
		return true
	return false
	
## 恢复
func restore(amount: int) -> void:
	current_value += amount
	current_value = min(current_value, max_value)
	print("技能资源恢复：{0} 恢复 {1} 点，当前值： {2} / {3}".format([
		ability_resource_name, amount, current_value, max_value
	]))
