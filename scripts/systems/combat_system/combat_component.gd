extends Node
class_name CombatComponent

## 战斗组件，负责单个单位的战斗行为
## 包括：
## 1. 战斗状态管理
## 2. 行动执行
## 3. 伤害处理


## 当前战斗单位是否存活
var is_alive: bool:
	get:
		return ability_resource_component.get_resource_value("health") > 0
## 行动速度
var speed: float:
	get:
		return ability_attribute_component.get_attribute_value("speed")


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
@export var _combat_camp: CombatDefinition.COMBAT_CAMP_TYPE = CombatDefinition.COMBAT_CAMP_TYPE.PLAYER		## 战斗阵营
@export_range(1, 4) var current_point: int = -1																## 当前所在位置
var current_action: CombatAction = null																		## 当前行动
var _ai_decision_marker: AIDecisionMaker = null																## AI决策标记

signal died
signal combat_started
signal turn_started
signal action_started
signal action_executing
signal action_executed
signal action_ended
signal turn_ended
signal combat_ended


func _ready() -> void:
	_ai_decision_marker = TurnBasedAIDecisionMaker.new()


## 设置组件依赖
## [param p_camp] 战斗阵营
## [param p_point] 当前位置
## [param p_ability_component] 技能组件
## [param p_ability_attribute_component] 属性组件
## [param p_ability_resource_component] 资源组件
func setup(
			p_camp : CombatDefinition.COMBAT_CAMP_TYPE,
			p_point: int,
			p_ability_component: AbilityComponent = null,
			p_ability_attribute_component: AbilityAttributeComponent = null,
			p_ability_resource_component: AbilityResourceComponent = null,
		) -> void:
	_combat_camp = p_camp
	current_point = p_point
	if p_ability_component:
		ability_component = p_ability_component
	if p_ability_attribute_component:
		ability_attribute_component = p_ability_attribute_component
	if p_ability_resource_component:
		ability_resource_component = p_ability_resource_component
	ability_resource_component.resource_current_value_changed.connect(_on_resource_current_value_changed)


#region 战斗流程处理


## 战斗开始
func combat_start() -> void:
	AbilitySystem.handle_game_event("combat_start", {"caster": get_parent()})
	combat_started.emit()
	current_action = _create_combat_action([], ability_component.get_abilities(["skill"])[0])
	current_action.target_changed.connect(
		func():
			if current_action.ability and not current_action.targets.is_empty():
				manual_action_start()
	)


## 回合开始
func turn_start() -> void:
	AbilitySystem.handle_game_event("turn_start", {"caster": get_parent()})
	turn_started.emit()


## 行动开始
func action_start() -> void:
	if not CombatSystem.active_combat_manager.is_auto and _combat_camp != CombatDefinition.COMBAT_CAMP_TYPE.ENEMY:
		# 非自动战斗且不是敌方，不选择技能
		return

	# 获取可用的技能
	var available_abilities : Array[Ability] = _get_available_abilities(current_point)
	if available_abilities.is_empty():
		return
	
	# AI选择技能和目标
	var selected_ability : TurnBasedSkillAbility = _ai_decision_marker.select_ability(available_abilities)
	if not selected_ability:
		return

	## 选择技能可用的目标
	var possible_targets = _get_possible_targets(selected_ability, {"position": current_point})
	## 选择目标
	var target : CombatComponent = _ai_decision_marker.select_target(selected_ability, possible_targets)
	if target.is_empty():
		return

	current_action = _create_combat_action([target.get_parent()], selected_ability)
	AbilitySystem.handle_game_event("action_start", {"caster": get_parent(), "targets": target, "ability": selected_ability})
	action_started.emit()


## 手动选择技能和目标
## [param ability] 选择的技能
## [param target] 选择的目标
func manual_action_start() -> void:
	var ability : TurnBasedSkillAbility = current_action.ability
	var target : Node = current_action.targets[0]
	
	if not ability or not target:
		return
	
	if current_action.targets != ability.get_actual_targets(current_action.targets, {"caster": get_parent()}):
		current_action.targets = ability.get_actual_targets(current_action.targets, {"caster": get_parent()})
		
	AbilitySystem.handle_game_event("action_start", {"caster": get_parent(), "target": target, "ability": ability})
	action_started.emit()
	CombatSystem.combat_action_started.push(current_action)


## 行动执行
func action_execute() -> void:
	if not _can_action():
		return
	if not current_action:
		push_error("没有行动, 请检查是否调用了 action_start!")
		return

	var ability_context := {
		"caster": current_action.actor,
		"targets": current_action.targets,
		"ability": current_action.ability,
		"tree": owner.get_tree(),
		"enemies": _get_enemies(),
		"allies": _get_allies(),
	}
	AbilitySystem.handle_game_event("action_executing", {"caster": get_parent(), "targets": current_action.targets, "ability": current_action.ability})
	action_executing.emit()
	await ability_component.try_execute_ability(current_action.ability, ability_context)
	AbilitySystem.handle_game_event("action_executed", {"caster": get_parent(), "targets": current_action.targets, "ability": current_action.ability})
	action_executed.emit()


## 行动结束
func action_end() -> void:
	AbilitySystem.handle_game_event("action_ended", {"caster": get_parent(), "targets": current_action.targets, "ability": current_action.ability})
	action_ended.emit()


## 回合结束
func turn_end() -> void:
	AbilitySystem.handle_game_event("turn_ended", {"caster": get_parent()})
	turn_ended.emit()


## 战斗结束
func combat_end() -> void:
	AbilitySystem.handle_game_event("combat_ended", {"caster": get_parent()})
	current_action = null
	combat_ended.emit()


#endregion 战斗流程处理


func get_camp() -> CombatDefinition.COMBAT_CAMP_TYPE:
	return _combat_camp


## 创建战斗行动
## [param targets] 目标
## [param ability] 技能
## [param delay] 延时
## [return] 战斗行动
func _create_combat_action(targets: Array[Node2D], ability: TurnBasedSkillAbility = null, delay: float = 0.2) -> CombatAction:
	return CombatAction.new( 
		get_parent(),  # 行动者节点
		targets,      # 目标节点
		ability,       # 技能
		delay          # 延时
	)


## 能否行动
func can_action() -> bool:
	return _can_action()


#region 内部方法


## 检查能否行动
func _can_action() -> bool:
	return is_alive and not owner.is_in_group("stunned")


## 死亡
func _die() -> void:
	ability_component.handle_game_event("on_die")
	died.emit()


## 获取可用的主动技能
## [param current_point] 当前位置
## [param friendly_units] 所有友方单位
## [param enemy_units] 所有敌方单位
## [return] 可用的主动技能
func _get_available_abilities( _current_point: int) -> Array[Ability]:
	var available_abilities: Array[Ability] = []
	for ability in ability_component.get_abilities(["skill"]):
		if ability.is_auto or not ability.is_active:
			continue
		if not ability is TurnBasedSkillAbility:
			continue
		if not ability.can_execute({"position": current_point}):
			continue
		available_abilities.append(ability)
	return available_abilities


func _get_possible_targets(ability: TurnBasedSkillAbility, context: Dictionary) -> Array[CombatComponent]:
	var units : Array[CombatComponent]
	var targets := ability.get_available_targets(context)
	for target in targets:
		units.append(target.combat_component)
	return units


## 获取所有的敌方单位
func _get_enemies() -> Array[Node]:
	var combat_manager : CombatManager = CombatSystem.active_combat_manager
	return combat_manager.get_enemy_units(get_parent())


## 获取所有的友方单位
func _get_allies() -> Array[Node]:
	var combat_manager : CombatManager = CombatSystem.active_combat_manager
	return combat_manager.get_ally_units(get_parent())


#endregion

func _on_resource_current_value_changed(res_id: StringName, value: float) -> void:
	if res_id == "health":
		if value <= 0.0:
			_die()


func _to_string() -> String:
	return "CombatComponent" + get_parent().to_string()
