extends Resource
class_name AbilityAttribute

## 技能属性类，代表技能依赖的一切属性，包括但不限于： 生命值、攻击力、防御力等

## 属性名称，相当于ID
@export var attribute_name : StringName
## 属性值
var attribute_value: float:
	get:
		return (_base_value + _value_modify) * (1 + _percentage_modify) + _absolute_modify
	set(value):
		assert(false, "只读属性，无法赋值")
## 属性基础值
@export var _base_value: float  # 基础值
## 数值修改值
var _value_modify : float
## 百分比修改值
var _percentage_modify: float
## 绝对值修改值
var _absolute_modify : float
## 属性调节器
var _modifiers: Array[AbilityAttributeModifier]

## 增加修改器
func add_modifier(modifier: AbilityAttributeModifier):
	assert(modifier.attribute_name == attribute_name, "属性名不一致无法添加修改器！")
	_modifiers.append(modifier)
	_update_modifiers()

## 移除修改器
func remove_modifier(modifier: AbilityAttributeModifier):
	_modifiers.erase(modifier)
	_update_modifiers()

## 更新修改器
func _update_modifiers() -> void:
	for modifier in _modifiers:
		if modifier.modify_type == AbilityDefinition.ATTRIBUTE_MODIFIER_TYPE.VALUE:
			_value_modify += modifier.value
		elif modifier.modify_type == AbilityDefinition.ATTRIBUTE_MODIFIER_TYPE.PERCENTAGE:
			_percentage_modify += modifier.value
		elif modifier.modify_type == AbilityDefinition.ATTRIBUTE_MODIFIER_TYPE.ABSOLUTE:
			_absolute_modify += modifier.value
