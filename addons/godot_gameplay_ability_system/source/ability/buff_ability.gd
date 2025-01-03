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
@export var value: int:
	set(v):
		value = v
		value_changed.emit(value)
## 是否允许堆叠
@export var can_stack : bool = false

signal value_changed(value: int)

## 应用技能
func apply(ability_component: AbilityComponent, context: Dictionary) -> void:
	var ability_context : Dictionary = context
	var _buff := ability_component.get_ability(_get_buff_name())
	if _buff:
		ability_component.remove_ability(_buff)
		if _buff.buff_type == AbilityDefinition.BUFF_TYPE.DURATION or _buff.can_stack:
			value += _buff.value
	ability_context["source"] = self
	ability_name = "buff_" + ability_name
	print("应用BUFF：", self)
	if not trigger:
		ability_component.try_cast_ability(self, context)
	super(ability_component, context)

## 移除技能
func remove(context: Dictionary = {}) -> void:
	super(context)

## 执行技能
func cast(context: Dictionary) -> bool:
	return await super(context)

## 更新BUFF状态
func update() -> void:
	print("更新{0} BUFF状态".format([self]))
	if buff_type == AbilityDefinition.BUFF_TYPE.VALUE:
		if not is_permanent: _ability_component.remove_ability(self, _context)
	elif buff_type == AbilityDefinition.BUFF_TYPE.DURATION:
		if not is_permanent:
			value -= 1
			if value <= 0:
				_ability_component.remove_ability(self, _context)
	print("更新buff {0} 的状态，完成！ 当前层数{1}".format([self, value]))

## 获取BUFF名
func _get_buff_name() -> StringName:
	return "buff_" + ability_name

func _to_string() -> String:
	return "{0}层数{1}".format([ability_name, value])
