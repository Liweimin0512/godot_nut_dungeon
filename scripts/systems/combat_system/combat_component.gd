extends Node
class_name CombatComponent

## 战斗组件，负责单个单位的战斗能力
## 包括：
## 1. 战斗属性管理
## 2. 技能使用和AI决策
## 3. 伤害处理

signal died

# 依赖组件
@export var ability_component: AbilityComponent:
	get:
		if not ability_component:
			ability_component = get_parent().ability_component
		return ability_component
@export var ability_resource_component: AbilityResourceComponent:
	get:
		if not ability_resource_component:
			ability_resource_component = get_parent().ability_resource_component
		return ability_resource_component
@export var ability_attribute_component: AbilityAttributeComponent:
	get:
		if not ability_attribute_component:
			ability_attribute_component = get_parent().ability_attribute_component
		return ability_attribute_component
@export var _combat_camp: CombatDefinition.COMBAT_CAMP_TYPE = CombatDefinition.COMBAT_CAMP_TYPE.PLAYER

var _ai_decision_maker: AIDecisionMaker

# 战斗属性
var is_alive: bool:
	get:
		return ability_resource_component.get_resource_value("health") > 0
var speed: float:
	get:
		return ability_attribute_component.get_attribute_value("speed")
## 所在战斗位置
var combat_point: int = -1

func _ready() -> void:
	ability_resource_component.resource_current_value_changed.connect(_on_resource_current_value_changed)
	_ai_decision_maker = TurnBasedAIDecisionMaker.new()

## 设置组件依赖
func setup(
			p_camp : CombatDefinition.COMBAT_CAMP_TYPE,
			p_ability_component: AbilityComponent = null,
			p_ability_attribute_component: AbilityAttributeComponent = null,
			p_ability_resource_component: AbilityResourceComponent = null,
		) -> void:
	_combat_camp = p_camp
	if p_ability_component:
		ability_component = p_ability_component
	if p_ability_attribute_component:
		ability_attribute_component = p_ability_attribute_component
	if p_ability_resource_component:
		ability_resource_component = p_ability_resource_component

## 执行技能
## 返回是否执行成功
func execute_ability(ability: TurnBasedSkillAbility, targets: Array[Node]) -> bool:
	if not _can_action() or not ability or targets.is_empty():
		return false
		
	var ability_context := {
		"caster": get_parent(),
		"targets": targets,
		"ability": ability,
		"tree": owner.get_tree(),
		"position": combat_point
	}
	
	if not ability.can_execute(ability_context):
		return false
		
	await ability_component.try_execute_ability(ability, ability_context)
	return true

## 自动选择并执行技能
## 返回是否成功选择并执行了技能
func auto_execute_ability() -> bool:
	var ability = auto_select_ability()
	if not ability:
		return false
		
	var targets = auto_select_targets(ability)
	if targets.is_empty():
		return false
		
	return await execute_ability(ability, targets)

## AI自动选择技能
## 返回选择的技能，如果没有可用技能返回null
func auto_select_ability() -> TurnBasedSkillAbility:
	var available_abilities = get_available_abilities()
	if available_abilities.is_empty():
		return null
	return _ai_decision_maker.select_ability(available_abilities)

## AI自动选择技能目标
## 返回选择的目标列表
func auto_select_targets(ability: TurnBasedSkillAbility) -> Array[Node2D]:
	if not ability:
		return []
	var possible_targets = get_possible_targets(ability)
	if possible_targets.is_empty():
		return []
	
	var selected_target = _ai_decision_maker.select_target(ability, possible_targets)
	if not selected_target:
		return []
		
	# 获取实际目标（可能包含AOE效果）
	return ability.get_actual_targets([selected_target], {
		"caster": get_parent(),
		"position": combat_point
	})

## 获取可用的主动技能
func get_available_abilities() -> Array[Ability]:
	var available_abilities: Array[Ability] = []
	for ability in ability_component.get_abilities(["skill"]):
		if ability.is_auto or not ability.is_active:
			continue
		if not ability is TurnBasedSkillAbility:
			continue
		if not ability.can_execute({"position": combat_point}):
			continue
		available_abilities.append(ability)
	return available_abilities

## 获取技能可用目标
func get_possible_targets(ability: TurnBasedSkillAbility) -> Array[Node2D]:
	return ability.get_available_targets({
		"caster": get_parent(),
		"tree": owner.get_tree(),
		"position": combat_point
	})

## 获取阵营
func get_camp() -> CombatDefinition.COMBAT_CAMP_TYPE:
	return _combat_camp

## 检查能否行动
func _can_action() -> bool:
	return is_alive and not owner.is_in_group("stunned")

## 处理死亡
func _on_resource_current_value_changed(res_id: StringName, value: float) -> void:
	if res_id == "health" and value <= 0.0:
		ability_component.handle_game_event("on_die")
		died.emit()

func _to_string() -> String:
	return "CombatComponent" + get_parent().to_string()
