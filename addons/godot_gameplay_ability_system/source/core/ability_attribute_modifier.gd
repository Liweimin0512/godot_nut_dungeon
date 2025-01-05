extends Resource
class_name AbilityAttributeModifier

## 属性调节器

## 被修改的属性名称
@export var attribute_name: StringName  
## 修改类型，使用枚举值
@export_enum("value", "percentage", "absolute") var modify_type: String = "value"
## 修改数值
@export var value: float
## 修改来源，例如装备、天赋或被动技能等
@export_storage var source: Node

## 添加修改器
func apply(attribute: AbilityAttribute) -> void:
	attribute.modify(modify_type, value)

## 移除修改器
func remove(attribute: AbilityAttribute) -> void:
	attribute.modify(modify_type, value * -1)

func _to_string() -> String:
	var s := "属性修改器：修改{0}属性".format([attribute_name])
	match modify_type:
		"value":
			s += "的值{0}".format([value])
		"percentage":
			s += "的百分比{0}%".format([value * 100])
		"absolute":
			s += "的绝对值{0}".format([value])
	return s
