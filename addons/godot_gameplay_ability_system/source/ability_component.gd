extends Node
class_name AbilityComponent

## 技能组件，管理技能属性，技能资源，技能（BUFF、SKILL）等

## 技能属性集
@export var _ability_attributes : Dictionary[StringName, AbilityAttribute]
## 当前单位所有的技能消耗资源，同名资源是单例
@export var _ability_resources : Dictionary[StringName, AbilityResource]
## 当前单位所拥有的全部技能（包括BUFF）
@export var _abilities : Dictionary[StringName, Ability]
## 技能触发器集
@export var _ability_triggers : Dictionary[StringName, Array]

## 属性变化时发出
signal attribute_changed(atr_name: StringName, value: float)
## 资源变化时发出
signal resource_changed(res_name: StringName, value: float)
## 技能释放前发出
signal pre_cast(ability: Ability)
## 技能释放时发出
signal ability_cast_finished(ability: Ability)
## 技能应用触发
signal ability_applied(ability: Ability)
## 技能移除触发
signal ability_removed(ability: Ability)

## 组件初始化
func initialization(
		attribute_set: Array[AbilityAttribute] = [],
		ability_resource_set : Array[AbilityResource] = [],
		ability_set : Array[Ability] = []) -> void:
	for attribute : AbilityAttribute in attribute_set:
		# attribute.initialization(self)
		if not _ability_attributes.has(attribute.attribute_name):
			_ability_attributes[attribute.attribute_name] = attribute
	for res : AbilityResource in ability_resource_set:
		res.initialization(self)
		_ability_resources[res.ability_resource_name] = res
		res.current_value_changed.connect(
			func(value: int) -> void:
				resource_changed.emit(res.ability_resource_name, value)
		)
	for ability in ability_set:
		ability.apply(self, {})
		_abilities[ability.ability_name] = ability
		ability.cast_finished.connect(
			func() -> void:
				ability_cast_finished.emit(ability)
		)
	print("ability_component: {0} 初始化".format([owner.to_string()]))

#region 技能属性相关

## 是否存在属性
func has_attribute(atr_name: StringName) -> bool:
	return _ability_attributes.has(atr_name)

## 获取属性
func get_attribute(atr_name: StringName) -> AbilityAttribute:
	var attribute : AbilityAttribute = _ability_attributes.get(atr_name)
	if attribute:
		return attribute
	return null

## 获取属性值
func get_attribute_value(atr_name : StringName) -> float:
	var attribute := get_attribute(atr_name)
	if attribute:
		return attribute.attribute_value
	#assert(false, "找不到需要的属性："+ atr_name)
	push_error("找不到需要的属性：" + atr_name)
	return -1

## 增加属性修改器
func apply_attribute_modifier(modifier: AbilityAttributeModifier):
	var attribute: AbilityAttribute = get_attribute(modifier.attribute_name)
	assert(attribute, "无效的属性：" + attribute.to_string())
	attribute.add_modifier(modifier)
	attribute_changed.emit(modifier.attribute_name, get_attribute_value(modifier.attribute_name))
	
## 移除属性修改器
func remove_attribute_modifier(modifier: AbilityAttributeModifier):
	var attribute: AbilityAttribute = get_attribute(modifier.attribute_name)
	assert(attribute, "无效的属性：" + attribute.to_string())
	attribute.remove_modifier(modifier)
	attribute_changed.emit(modifier.attribute_name, get_attribute_value(modifier.attribute_name))

## 获取属性的所有修改器
func get_attribute_modifiers(attribute_name: StringName) -> Array[AbilityAttributeModifier]:
	var attribute := get_attribute(attribute_name)
	if attribute:
		return attribute.get_modifiers()
	return []

#endregion

#region 消耗资源相关

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

#endregion

#region 技能相关

## 获取相同名称的技能
func get_same_ability(ability: Ability) -> Ability:
	var ability_key = ability.get_class() + "_" + ability.ability_name
	return _abilities.get(ability_key)

## 获取全部技能
func get_abilities() -> Array[Ability]:
	var abilities : Array[Ability] = []
	for ability : Ability in _abilities.values():
		abilities.append(ability)
	return abilities

## 应用技能
func apply_ability(ability: Ability, ability_context: Dictionary) -> void:
	ability.apply(self, ability_context)
	# 使用类型名+技能名作为key,避免不同派生类对象名称重复
	var ability_key = ability.get_class() + "_" + ability.ability_name
	_abilities[ability_key] = ability
	ability_applied.emit(ability)

## 移除技能
func remove_ability(ability: Ability) -> void:
	ability.remove()
	var key : StringName = _abilities.find_key(ability)
	if key: _abilities.erase(key)
	print("移除Ability：", ability)
	ability_removed.emit(ability)

## 尝试释放技能
func try_cast_ability(ability: Ability, context: Dictionary) -> bool:
	#var caster : Node = context.caster
	print("ability_component: {0}尝试释放技能：{1}".format([self, ability]))
	pre_cast.emit(ability)
	await ability.cast(context)
	print("ability: {0}释放技能：{1}".format([self, ability]))
	return true

#endregion

#region 触发器相关

## 处理游戏事件
func handle_game_event(event_name: StringName, event_context: Dictionary = {}) -> void:
	GASLogger.info("接收到游戏事件：{0}，事件上下文{1}".format([event_name, event_context]))
	_handle_resource_callback(event_name, event_context)
	for ability in _abilities.values():
		# if ability.trigger and ability.trigger.trigger_type == event_name:
		# 	if ability.trigger.check(event_context):
		# 		print("处理游戏事件：{0}，事件上下文{1}，触发技能{2}".format([event_name, event_context, ability]))
		# 		await try_cast_ability(ability, event_context)
		if ability.has_method(event_name):
			ability.call(event_name, event_context)
	var triggers : Array = _ability_triggers.get(event_name, [])
	if triggers.is_empty():
		GASLogger.info("没有找到触发器：{0}".format([event_name]))
		return
	for trigger : AbilityEffectTriggerNode in triggers:
		trigger.handle_trigger(event_context)

## 添加触发器
func add_ability_trigger(trigger_type: StringName, trigger: AbilityEffectTriggerNode) -> void:
	var triggers : Array[AbilityEffectTriggerNode] = _ability_triggers.get(trigger_type, [])
	triggers.append(trigger)
	_ability_triggers[trigger_type] = triggers

## 移除触发器
func remove_ability_trigger(trigger_type: StringName, trigger: AbilityEffectTriggerNode) -> void:
	var triggers : Array[AbilityEffectTriggerNode] = _ability_triggers.get(trigger_type, [])
	if triggers.has(trigger):
		triggers.erase(trigger)
		_ability_triggers[trigger_type] = triggers

#endregion

## 应用伤害
func apply_damage(damage: AbilityDamage) -> void:
	var health : AbilityResource = get_resource("生命值")
	health.consume(round(damage.damage_value))

func _to_string() -> String:
	return owner.to_string()
