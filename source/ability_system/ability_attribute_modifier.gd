extends Resource
class_name AbilityAttributeModifier

## 属性调节器

## 被修改的属性名称
@export var attribute_name: StringName  
## 修改类型，使用枚举值
@export var modify_type: AbilityDefinition.ATTRIBUTE_MODIFIER_TYPE
## 修改数值
@export var value: float
## 修改来源，例如装备、天赋或被动技能等
@export_storage var source: Node
