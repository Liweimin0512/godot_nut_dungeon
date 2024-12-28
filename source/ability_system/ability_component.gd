extends Node
class_name AbilityComponent

## 技能组件

## 技能属性集
@export var ability_attributes : Array[AbilityAttribute]
## 当前单位所有的技能消耗资源
@export var ability_resources : Array[AbilityResource]
## 当前单位所拥有的全部技能(包括BUFF)
@export var abilities : Array[Ability]
## 技能执行上下文
var _ability_context : Dictionary

## 属性变化时发出
signal attribute_changed(atr_name: StringName, value: float)
## 资源变化时发出
signal resource_changed(res_name: StringName, value: float)
## 技能释放时发出
signal ability_cast_finished(ability: Ability)

## 组件初始化
func initialization(context: Dictionary = {}) -> void:
	_ability_context = context
	for res : AbilityResource in ability_resources:
		res.initialization(self, _ability_context)
		res.current_value_changed.connect(
			func(value: int) -> void:
				resource_changed.emit(res.ability_resource_name, value)
		)
	for ability in abilities:
		ability.initialization(self, _ability_context)
		ability.cast_finished.connect(
			func() -> void:
				ability_cast_finished.emit(ability)
		)

#region 技能属性相关

## 获取属性
func get_attribute(atr_name: StringName) -> AbilityAttribute:
	for atr : AbilityAttribute in ability_attributes:
		if atr.attribute_name == atr_name:
			return atr
	return null

## 获取属性值
func get_attribute_value(atr_name : StringName) -> float:
	var atr := get_attribute(atr_name)
	if atr:
		return atr.attribute_value
	assert(false, "找不到需要的属性："+ atr_name)
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
	for res : AbilityResource in ability_resources:
		if res.ability_resource_name == res_name:
			return res
	return null

## 消耗资源
func consume_resources(res_name: StringName, cost: int) -> bool:
	var res := get_resource(res_name)
	if res:
		return res.consume(cost)
	return false

## 触发资源回调
func _callback_resource(callback_name: StringName, callbakc_params : Array) -> void:
	for res : AbilityResource in ability_resources:
		if res.has_method(callback_name):
			res.callv(callback_name, callbakc_params)

#endregion

#region 技能相关

## 获取可用主动技能
func get_available_abilities() -> Array[Ability]:
	var available_abilities : Array[Ability] = abilities.filter(
		func(ability: Ability) -> bool:
			return _is_ability_available(ability)
	)
	return available_abilities

## 尝试释放技能
func try_cast_ability(ability: Ability, context:Dictionary = {}) -> void:
	if not has_enough_resources(ability.cost_resource_name, ability.cost_resource_value):
		print("消耗不足，无法释放技能！")
		return
	if ability.is_cooldown:
		print("技能正在冷却！")
		return
	await get_tree().create_timer(0.5).timeout
	var caster : Node = context.caster
	consume_resources(ability.cost_resource_name, ability.cost_resource_value)
	print("ability: {0}释放技能：{1}".format([caster, ability]))
	for effect : AbilityEffect in ability.effects:
		effect.apply_effect(context)
	ability.current_cooldown = ability.cooldown

## 更新技能冷却计时，在回合开始前
func update_ability_cooldown() -> void:
	for ability : Ability in abilities:
		if not ability is SkillAbility: continue
		if ability.is_cooldown:
			ability.current_cooldown -= 1

## 判断技能是否可用
func _is_ability_available(ability: Ability) -> bool:
	## 这个方法用来筛选哪些可用的主动技能
	return not ability.is_cooldown and not ability.is_auto_cast and has_enough_resources(ability.cost_resource_name, ability.cost_resource_value)

## 应用技能
func apply_ability(ability: Ability) -> void:
	ability.initialization(self, _ability_context)
	if ability is SkillAbility:
		if ability.is_auto_cast and ability.trigger == null:
			try_cast_ability(ability)
	elif ability is BuffAbility:
		var _buff := get_buff_ability(ability.buff_name)
		if _buff:
			remove_ability(_buff)
			if _buff.buff_type == AbilityDefinition.BUFF_TYPE.DURATION or _buff.can_stack:
				ability.value += _buff.value
		_ability_context["source"] = ability
		print("应用BUFF：", ability)
	for effect in ability.effects:
		effect.apply_effect(_ability_context)
	abilities.append(ability)

## 移除技能
func remove_ability(ability: Ability) -> void:
	abilities.erase(ability)
	for effect in ability.effects:
		effect.remove_effect(_ability_context)
	print("移除Ability：", ability)

## 获取BUFF技能
func get_buff_ability(buff_name : StringName) -> BuffAbility:
	for ability in abilities:
		if ability is BuffAbility and ability.ability_name	 == buff_name:
			return ability
	return null

## 获取SKILL技能
func get_skill_ability(skill_name : StringName) -> SkillAbility:
	for ability in abilities:
		if ability is SkillAbility and ability.ability_name	 == skill_name:
			return ability
	return null

## 获取所有BUFF技能
func get_buffs() -> Array[BuffAbility]:
	return abilities.filter(
		func(ability: Ability) -> bool:
			return ability is BuffAbility
			)

## 更新BUFF状态
func update_buffs() -> void:
	for buff in get_buffs():
		if buff.buff_type == AbilityDefinition.BUFF_TYPE.VALUE:
			if not buff.is_permanent: remove_ability(buff)
		elif buff.buff_type == AbilityDefinition.BUFF_TYPE.DURATION:
			if not buff.is_permanent:
				buff.value -= 1
				if buff.value <= 0:
					remove_ability(buff)

#endregion

## 处理游戏事件
func handle_game_event(event_name: StringName, event_context: Dictionary = {}) -> void:
	_callback_resource(event_name, event_context.values())
	for ability in abilities:
		if ability.trigger and ability.trigger.trigger_name == event_name:
			if ability.trigger.check(event_context):
				try_cast_ability(ability)