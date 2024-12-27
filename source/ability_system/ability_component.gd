extends Node
class_name AbilityComponent

## 技能组件

## 技能属性集
@export var ability_attributes : Array[AbilityAttribute]
## 技能属性修改器集
@export_storage var attribute_modifiers : Array[AbilityAttributeModifier]
## 当前单位所有的技能消耗资源
@export var ability_resources : Array[AbilityResource]
## 当前单位所拥有的全部技能
@export var abilities : Array[Ability]
## BUFF集
@export var buffs : Array[AbilityBuff]
## 技能执行上下文
var context : Dictionary :
	set(value):
		context = value
		for effect in _get_all_effects():
			effect.update_context(context)

signal attribute_changed(atr_name: StringName, value: float)
signal resource_changed(res_name: StringName, value: float)
signal cast_finished(ability: Ability)

## 组件初始化
func initialization(caster: Node) -> void:
	context["caster"] = caster
	for res : AbilityResource in ability_resources:
		res.initialization(self)
		res.current_value_changed.connect(
			func(value: int) -> void:
				resource_changed.emit(res.ability_resource_name, value)
		)
	for ability in abilities:
		ability.initialization(context)
		ability.cast_finished.connect(
			func() -> void:
				cast_finished.emit(ability)
		)

#region 技能属性相关
## 获取属性值
func get_attribute_value(atr_name : StringName) -> float:
	var atr := get_attribute(atr_name)
	if atr:
		return atr.attribute_value
	assert(false, "找不到需要的属性："+ atr_name)
	return -1

## 获取属性
func get_attribute(atr_name: StringName) -> AbilityAttribute:
	for atr : AbilityAttribute in ability_attributes:
		if atr.attribute_name == atr_name:
			return atr
	return null

## 增加属性修改器
func apply_attribute_modifier(modifier: AbilityAttributeModifier):
	var attribute: AbilityAttribute = get_attribute(modifier.attribute_name)
	assert(attribute, "无效的属性：" + attribute.to_string())
	attribute_modifiers.append(modifier)
	modifier.apply(attribute)
	attribute_changed.emit(modifier.attribute_name, get_attribute_value(modifier.attribute_name))
	
## 移除属性修改器
func remove_attribute_modifier(modifier: AbilityAttributeModifier):
	var attribute: AbilityAttribute = get_attribute(modifier.attribute_name)
	assert(attribute, "无效的属性：" + attribute.to_string())
	attribute_modifiers.erase(modifier)
	modifier.remove(attribute)
	attribute_changed.emit(modifier.attribute_name, get_attribute_value(modifier.attribute_name))

## 获取属性的所有修改器
func get_attribute_modifiers(attribute_name: StringName) -> Array[AbilityAttributeModifier]:
	var attribute_modifiers: Array[AbilityAttributeModifier]
	return attribute_modifiers

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

#endregion

#region 技能相关
## 获取可用技能
func get_available_abilities() -> Array[Ability]:
	var available_abilities : Array[Ability] = abilities.filter(
		func(ability: Ability) -> bool:
			return _is_ability_available(ability)
	)
	return available_abilities

## 尝试释放技能
func try_cast_ability(ability: Ability, targets : Array) -> void:
	if not has_enough_resources(ability.cost_resource_name, ability.cost_resource_value):
		print("消耗不足，无法释放技能！")
		return
	if ability.is_cooldown:
		print("技能正在冷却！")
		return
	await get_tree().create_timer(0.5).timeout
	var caster : Node = context.caster
	consume_resources(ability.cost_resource_name, ability.cost_resource_value)
	var context : Dictionary = {} if targets.is_empty() else {
		"targets" : targets
	}
	print("ability: {0}释放技能：{1}".format([caster, ability]))
	for effect : AbilityEffect in ability.effects:
		effect.apply_effect(context)
	ability.current_cooldown = ability.cooldown

## 判断技能是否可用
func _is_ability_available(ability: Ability) -> bool:
	## 这个方法用来筛选哪些可用的主动技能
	return not ability.is_cooldown and not ability.is_auto_cast and has_enough_resources(ability.cost_resource_name, ability.cost_resource_value)

## 更新技能冷却计时，在回合开始前
func _update_ability_cooldown() -> void:
	for ability : Ability in abilities:
		if ability.is_cooldown:
			ability.current_cooldown -= 1

func _get_all_effects() -> Array[AbilityEffect]:
	var effects : Array[AbilityEffect]
	for ability in abilities:
		effects += ability.effects
	for buff in buffs:
		effects += buff.effects
	return effects
#endregion

#region BUFF相关

func apply_buff(buff: AbilityBuff) -> void:
	var _buff := get_buff(buff.buff_name)
	if _buff:
		remove_buff(_buff)
		if _buff.buff_type == AbilityDefinition.BUFF_TYPE.DURATION or _buff.can_stack:
			buff.value += _buff.value
	buffs.append(buff)
	var _context := context.duplicate()
	_context["source"] = buff
	for effect in buff.effects:
		effect.apply_effect(_context)
	print("应用BUFF：", buff)

func remove_buff(buff: AbilityBuff) -> void:
	buffs.erase(buff)
	for effect in buff.effects:
		effect.remove_effect(context)
	print("移除BUFF：", buff)

func get_buff(buff_name : StringName) -> AbilityBuff:
	for buff in buffs:
		if buff.buff_name == buff_name:
			return buff
	return null

#endregion

#region 触发时机回调函数

## 战斗开始
func on_combat_start() -> void:
	for res : AbilityResource in ability_resources:
		res.on_combat_start()
	for effect in _get_all_effects():
		if effect.has_method("on_combat_start"):
			effect.on_combat_start()

## 战斗结束
func on_combat_end() -> void:
	for res : AbilityResource in ability_resources:
		res.on_combat_end()
	for effect in _get_all_effects():
		if effect.has_method("on_combat_end"):
			effect.on_combat_end()
	for buff in buffs:
		remove_buff(buff)

## 回合开始
func on_turn_start() -> void:
	# 回合开始时更新技能的冷却计时
	_update_ability_cooldown()
	for res : AbilityResource in ability_resources:
		res.on_turn_start()
	for effect in _get_all_effects():
		if effect.has_method("on_turn_start"):
			effect.on_turn_start()
	for buff in buffs:
		if buff.buff_type == AbilityDefinition.BUFF_TYPE.VALUE:
			if not buff.is_permanent: remove_buff(buff)
		elif buff.buff_type == AbilityDefinition.BUFF_TYPE.DURATION:
			if not buff.is_permanent:
				buff.value -= 1
				if buff.value <= 0:
					remove_buff(buff)

## 回合结束
func on_turn_end() -> void:
	for res : AbilityResource in ability_resources:
		res.on_turn_end()
	for effect in _get_all_effects():
		if effect.has_method("on_turn_end"):
			effect.on_turn_end()

## 造成伤害
func on_hit() -> void:
	for res : AbilityResource in ability_resources:
		res.on_hit()
	for effect in _get_all_effects():
		if effect.has_method("on_hit"):
			effect.on_hit()

## 受到伤害
func on_hurt(source: Node, damage: float) -> void:
	for res : AbilityResource in ability_resources:
		res.on_hurt()
	for effect in _get_all_effects():
		if effect.has_method("on_hurt"):
			effect.on_hurt({
			"source": source,
			"damage": damage
		})

## 死亡
func on_die() -> void:
	for res : AbilityResource in ability_resources:
		res.on_die()
	for effect in _get_all_effects():
		if effect.has_method("on_die"):
			effect.on_die()
#endregion
