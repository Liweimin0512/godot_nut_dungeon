extends Node

## 战斗系统单例，负责管理战斗流程和战斗实例的生命周期
## 包括：
## 1. 战斗配置管理
## 2. 战斗流程控制
## 3. 战斗单位管理
## 4. 战斗事件分发

const COMBAT_STATE_MACHINE : StringName = &"combat"

# 战斗状态
var current_turn: int = 0							## 当前回合数
var is_combat_active: bool = false					## 是否正在进行战斗
var is_auto: bool = true:							## 是否为自动战斗
	get:
		return _combat_config.is_auto if _combat_config else is_auto

# 战斗单位
var _players: Array[Node] = []						## 玩家单位列表
var _enemies: Array[Node] = 	[]					## 敌人单位列表
var _action_order: Array = []						## 行动顺序
var _current_action : CombatAction					## 当前行动

# 系统状态
var _initialized: bool = false
var _combat_model_type: ModelType
var _combat_config: CombatModel
## 单位战斗组件
var _combat_components : Dictionary[Node, CombatComponent]

# 状态机管理
var _state_machine_manager: CoreSystem.StateMachineManager:
	get:
		return CoreSystem.state_machine_manager

#region 战斗事件系统
## 战斗生命周期事件
var combat_created := CombatEvent.new(&"combat_created")         ## 战斗创建
var combat_started := CombatEvent.new(&"combat_started")         ## 战斗开始
var combat_ended := CombatEvent.new(&"combat_ended")             ## 战斗结束

## 回合事件
var combat_turn_started := CombatEvent.new(&"combat_turn_started")   ## 回合开始
var combat_turn_executed := CombatEvent.new(&"combat_turn_executed") ## 回合执行
var combat_turn_ended := CombatEvent.new(&"combat_turn_ended")       ## 回合结束

## 行动事件
var combat_action_selecting := CombatEvent.new(&"combat_action_selecting") ## 行动选择中
var combat_action_selected := CombatEvent.new(&"combat_action_selected")   ## 行动已选择
var combat_action_started := CombatEvent.new(&"combat_action_started")     ## 行动开始
var combat_action_executing := CombatEvent.new(&"combat_action_executing") ## 行动执行中
var combat_action_executed := CombatEvent.new(&"combat_action_executed")   ## 行动已执行
var combat_action_ended := CombatEvent.new(&"combat_action_ended")         ## 行动结束

## 技能事件
var action_ability_selected := CombatEvent.new(&"action_ability_selected") ## 技能选择
var action_target_selected := CombatEvent.new(&"action_target_selected")   ## 目标选择
#endregion

var _logger: CoreSystem.Logger = CoreSystem.logger

signal initialized(success: bool)

## 初始化战斗系统
func initialize(combat_model_type: ModelType) -> bool:
	if _initialized:
		return true

	_combat_model_type = combat_model_type
	
	# 初始化战斗相关的子系统
	DataManager.load_model(combat_model_type,
		func(_result: Variant):
			_initialized = true
			initialized.emit(_initialized)
	)
	return true


## 创建新的战斗实例
func create_combat(combat_id: StringName) -> void:
	# 如果已有活跃战斗，先结束它
	if is_combat_active:
		end_combat()
	
	# 设置战斗配置和单位
	_combat_config = DataManager.get_data_model(_combat_model_type.model_name, combat_id)


	_players = _setup_players()
	_enemies = _create_enemy_units()

	# 初始化战斗状态
	current_turn = 0
	is_combat_active = false
	_action_order.clear()
	
	# TODO 测试修改
	_combat_config.is_auto = false
	
	# 创建并注册状态机
	_state_machine_manager.register_state_machine(COMBAT_STATE_MACHINE, CombatStateMachine.new(), self)
	combat_created.push([_players, _enemies])

	# 启动战斗
	_startup_combat()

#region 战斗流程相关

## 开始战斗
func start_combat() -> void:
	if is_combat_active:
		return

	current_turn = 0
	
	_state_machine_manager.start_state_machine(COMBAT_STATE_MACHINE, &"combat_start")
	is_combat_active = true
	combat_started.push()


## 开始新回合
func start_turn() -> void:
	if not is_combat_active:
		return
		
	current_turn += 1
	_action_order = _sort_units_by_speed()
	
	combat_turn_started.push()

## 开始行动
func start_action() -> void:
	if not is_combat_active or _action_order.is_empty():
		_logger.error("开始行动时战斗已结束或行动队列为空")
		return
	
	# 开始行动时创建CombatAction并默认选择第一个技能
	var current_actor = _action_order.pop_front()
	_current_action = _create_combat_action(current_actor)
	combat_action_started.push([_current_action])
	_logger.debug("开始行动:%s" % _current_action)

## 是否为自动行动
func is_auto_action() -> bool:
	if not _current_action:
		_logger.error("当前行动为空")
		return false
	var component = get_combat_component(_current_action.actor)
	if not component:
		return false
		
	return is_auto or component.get_camp() == CombatDefinition.COMBAT_CAMP_TYPE.ENEMY

## 自动行动
func start_auto_action() -> void:
	if not is_auto_action():
		_logger.error("不是自动行动")
		return
	_current_action.ability = _auto_select_ability()
	_current_action.targets = _auto_select_targets()	

## 手动行动
func start_manual_action() -> void:
	combat_action_selecting.push(_current_action)

## 选择技能
func select_ability(ability : TurnBasedSkillAbility) -> void:
	_current_action.ability = ability
	action_ability_selected.push()

## 选择目标
func select_target(target: Node) -> void:
	_current_action.targets = [target]
	action_target_selected.push()

## 执行行动
func execute_action() -> void:
	if not _current_action:
		_logger.error("当前行动为空，无法执行！")
		return
	var component : CombatComponent = get_combat_component(_current_action.actor)
	_logger.debug("执行行动前：%s" % _current_action)
	combat_action_executing.push()
	await component.execute_ability(_current_action.ability, _current_action.targets)
	_logger.debug("执行行动：%s" % _current_action)
	combat_action_executed.push()

## 结束行动
func end_action() -> void:
	_logger.debug("结束行动：%s" % _current_action)
	_current_action = null

func is_all_units_executed() -> bool:
	return _action_order.is_empty()

func end_turn() -> void:
	combat_turn_ended.push()

## 结束当前战斗
func end_combat() -> void:
	if not is_combat_active:
		_logger.error("结束战斗时战斗已结束！")
		return
	is_combat_active = false
	current_turn = 0
	_players.clear()
	_enemies.clear()
	_action_order.clear()
	if _current_action:
		_logger.warning("结束战斗时存在当前行动！")
	_current_action = null
	
	_state_machine_manager.unregister_state_machine(COMBAT_STATE_MACHINE)
	combat_ended.push(self)

func check_victory_condition() -> bool:
	for unit in _enemies:
		var component : = get_combat_component(unit)
		if component and component.is_alive:
			return false
	return true

func check_defeat_condition() -> bool:
	for unit in _players:
		var component : = get_combat_component(unit)
		if component and component.is_alive:
			return false
	return true

func combat_victory() -> void:
	pass

func combat_defeat() -> void:
	pass

func is_max_turn_count_reached() -> bool:
	return current_turn >= _combat_config.max_turn_count

#endregion

func get_action_order() -> Array:
	return _action_order

## 获取单位的战斗组件
func get_combat_component(unit: Node) -> CombatComponent:
	if not unit:
		return null
	var component : CombatComponent = _combat_components.get(unit, null)
	if not component:
		component = unit.get("combat_component")
		if not component:
			component = unit.get_node_or_null("CombatComponent")
		_combat_components[unit] = component
	return component

## 获取指定单位的敌人列表
func get_enemy_units(unit: Node) -> Array[Node]:
	var component := get_combat_component(unit)
	if not component:
		return []
	return _enemies if component.get_camp() == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER else _players

## 获取指定单位的盟友列表
func get_ally_units(unit: Node) -> Array[Node]:
	var component := get_combat_component(unit)
	if not component:
		return []
	return _players if component.get_camp() == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER else _enemies

## 获取战斗配置
func get_combat_config() -> CombatModel:
	return _combat_config


## 按速度排序所有存活单位
func _sort_units_by_speed() -> Array:
	var units := []
	units.append_array(_players)
	units.append_array(_enemies)
	
	# 过滤掉死亡单位
	units = units.filter(func(unit: Node) -> bool:
		var component = get_combat_component(unit)
		return component and component.is_alive
	)
	
	# 按速度排序
	units.sort_custom(func(a: Node, b: Node) -> bool:
		var comp_a = get_combat_component(a)
		var comp_b = get_combat_component(b)
		return comp_a.speed > comp_b.speed if comp_a and comp_b else false
	)
	
	return units

## 创建敌人单位
func _create_enemy_units() -> Array[Node]:
	var units: Array[Node] = []

	var index := 1
	for i in range(_combat_config.enemy_data.size()):
		var entityID : StringName = _combat_config.enemy_data[i]
		if entityID.is_empty():
			continue
		
		var character: Character = CharacterSystem.create_character(entityID)
		var combt_component = get_combat_component(character)
		combt_component.combat_point = index
		units.append(character)
		index += 1
	return units

## 设置玩家单位
func _setup_players() -> Array[Node]:
	var units : Array[Node] = []
	var index := 1
	for cha in PartySystem.get_active_party():
		if not cha:
			continue
		units.append(cha)
		var component = get_combat_component(cha)
		component.combat_point = index
		index += 1
	return units


## 启动战斗
func _startup_combat() -> void:
	if not is_combat_active:
		_state_machine_manager.start_state_machine(COMBAT_STATE_MACHINE, &"combat_startup")


func _create_combat_action(actor : Node) -> CombatAction:
	var ability_component = AbilitySystem.get_ability_component(actor)
	var combat_action = CombatAction.new(actor, [], ability_component.get_abilities(["skill"])[0])
	return combat_action


func _auto_select_ability() -> TurnBasedSkillAbility:
	if not _current_action:
		_logger.error("当前行动为空")
		return null
	var actor = _current_action.actor
	var combat_component = get_combat_component(actor)
	return combat_component.auto_select_ability()


func _auto_select_targets() -> Array[Node]:
	if not _current_action:
		_logger.error("当前行动为空")
		return []
	var actor = _current_action.actor
	var ability = _current_action.ability
	var combat_component = get_combat_component(actor)
	return combat_component.auto_select_targets(ability)
