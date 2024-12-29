extends AbilityEffect
class_name ModifyResourceEffect

## 修改技能资源值

## 获取的技能资源名
@export var ability_resource_name: StringName = ""
## 获得的技能资源数量
@export var ability_resource_amount: int = 5

func apply_effect(context: Dictionary = {}) -> void:
	var caster : Node = context.caster
	var ability_component : AbilityComponent = caster.ability_component
	var ability_resource : AbilityResource = ability_component.get_resource(ability_resource_name)
	if ability_resource_amount > 0:
		ability_resource.restore(ability_resource_amount)
	else:
		ability_resource.consume(ability_resource_amount)
	print("受到攻击，触发{0}，获得{1}点{2}".format([
		description, ability_resource_amount, ability_resource_name
	]))
	super()

func _description_getter() -> String:
	return "获得{0}点{1}".format([
		ability_resource_amount, ability_resource_name
		])
