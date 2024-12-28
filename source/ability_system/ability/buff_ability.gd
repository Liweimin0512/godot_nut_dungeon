extends Ability
class_name BuffAbility

## BUFF系统，自管理生命周期的被动技能
## Buff系统允许角色在战斗中获得临时的增益效果，
## 这些效果可以增强角色的属性、提供特殊能力或影响战斗的其他方面。
## Buff可以来自技能、物品、环境等多种来源。

## buff类型
@export var buff_type: AbilityDefinition.BUFF_TYPE
## 是否永久, 永久指持续到战斗结束
@export var is_permanent: bool = false
## buff值，含义取决于BUFF类型，数值型代表层数，持续型代表持续时间
@export var value: int
## 是否允许堆叠
@export var can_stack : bool = false

func _to_string() -> String:
	return "{0}层数{1}".format([ability_name, value])
