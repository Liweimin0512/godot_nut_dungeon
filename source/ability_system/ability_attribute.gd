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

func _init(atr_name : StringName = "", base: float = 0) -> void:
	attribute_name = atr_name
	_base_value = base

func _to_string() -> String:
	return "{attribute_name} : {attribute_value}".format({
		"attribute_name": attribute_name,
		"attribute_value": attribute_value
	})

func modify(modify_type: AbilityDefinition.ATTRIBUTE_MODIFIER_TYPE, value: float) -> void:
	match modify_type:
		AbilityDefinition.ATTRIBUTE_MODIFIER_TYPE.VALUE:
			_value_modify += value
		AbilityDefinition.ATTRIBUTE_MODIFIER_TYPE.PERCENTAGE:
			_percentage_modify += value
		AbilityDefinition.ATTRIBUTE_MODIFIER_TYPE.ABSOLUTE:
			_absolute_modify = value
