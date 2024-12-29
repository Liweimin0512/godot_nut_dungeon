extends AbilityEffect
class_name ModifyResourceEffect

## 修改技能资源值

## 获取的技能资源名
@export var ability_resource_name: StringName = ""
## 获得的技能资源数量
@export var ability_resource_amount: float = 5
## 资源修改方式
@export_enum("value", "percentage") var modify_type : String = "value"

func apply_effect(context: Dictionary = {}) -> void:
	var caster : Node = context.caster
	var ability_component : AbilityComponent = caster.ability_component
	var ability_resource : AbilityResource = ability_component.get_resource(ability_resource_name)
	var _amount := ability_resource_amount
	if modify_type == "percentage":
		_amount = ability_component.get_resource_value(ability_resource_name) * _amount
	if ability_resource_amount > 0:
		ability_resource.restore(_amount)
	else:
		ability_resource.consume(_amount)
	print("受到攻击，触发{0}，获得{1}点{2}".format([
		description, ability_resource_amount, ability_resource_name
	]))
	super()

func _description_getter() -> String:
	return "获得{0}点{1}".format([
		ability_resource_amount, ability_resource_name
		])
