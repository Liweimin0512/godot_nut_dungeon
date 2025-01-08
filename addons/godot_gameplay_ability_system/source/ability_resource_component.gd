extends Node
class_name AbilityCostComponent

## 技能消耗组件

## 当前单位所有的技能消耗资源，同名资源是单例
@export var _ability_resources : Dictionary[StringName, AbilityResource]

## 资源变化时发出
signal resource_changed(res_name: StringName, value: float)

## 检查资源是否足够消耗
func has_enough_resources(res_name: StringName, cost: int) -> bool:
	if res_name.is_empty(): return true
	return get_resource_value(res_name) >= cost

## 获取资源数量
func get_resource_value(res_name: StringName) -> int:
	var res := get_resource(res_name)
	if res:
		return res.current_value
	return -1

## 获取资源
func get_resource(res_name: StringName) -> AbilityResource:
	var res : AbilityResource = _ability_resources.get(res_name)
	if res:
		return res
	return null

## 消耗资源
func consume_resources(res_name: StringName, cost: int) -> bool:
	var res := get_resource(res_name)
	if res:
		return res.consume(cost)
	return false

## 获取所有资源
func get_resources() -> Array[AbilityResource]:
	var _resources : Array[AbilityResource]
	for res : AbilityResource in _ability_resources.values():
		_resources.append(res)
	return _resources

## 触发资源回调
func _handle_resource_callback(callback_name: StringName, context : Dictionary) -> void:
	for res : AbilityResource in _ability_resources.values():
		if res.has_method(callback_name):
			res.call(callback_name, context)

## 消耗技能
func cost_ability(ability: Ability, context: Dictionary) -> bool:
	if not ability.ability_cost.can_cost(context):
		return false
	ability.ability_cost.cost(context)
	return true

## 是否能消耗技能
func can_cost_ability(ability: Ability, context: Dictionary) -> bool:
	return ability.ability_cost.can_cost(context)
