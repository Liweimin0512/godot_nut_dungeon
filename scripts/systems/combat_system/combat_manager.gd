extends Resource
class_name CombatManager

## 战斗管理器，负责管理整个战斗流程
## 包括：
## 1. 战斗单位的注册和管理
## 2. 回合制战斗流程的控制
## 3. 目标选择系统
## 4. 战斗行动的执行

# 战斗配置

# 战斗状态
## 当前回合数
var current_turn: int = 0
## 是否战斗中
var is_combat_active: bool = false
## 是否自动战斗
var is_auto: bool:
	get:
		return _combat_config.is_auto

# 战斗单位
## 玩家单位
var player_combats: Array[CombatComponent] = []
## 敌人单位
var enemy_combats: Array[CombatComponent] = []
## 角色行动顺序
var action_order: Array[CombatComponent] = []
var prepared_units : int = 0

## 所有信号通过事件总线推送
var _event_bus : CoreSystem.EventBus:
	get:
		return CoreSystem.event_bus
var _combat_config : CombatModel

## 当前行动的角色
var _current_action_unit : CombatComponent

func _init(
		combat_info: CombatModel,
		p_player_combats: Array[CombatComponent],
		p_enemy_combats: Array[CombatComponent],
		) -> void:
	_combat_config = combat_info
	player_combats = p_player_combats
	enemy_combats = p_enemy_combats

## 初始化战斗
func initialize() -> void:
	# 初始化战斗状态
	current_turn = 0
	is_combat_active = false

## 开始战斗
func start_combat() -> void:
	if is_combat_active:
		return	
	is_combat_active = true
	current_turn = 0

	# 通知所有单位开始战斗
	for unit in player_combats + enemy_combats:
		await unit.combat_start()

	CombatSystem.combat_started.push(self)

## 开始新回合
func start_turn() -> void:
	if not is_combat_active:
		return
	current_turn += 1
	action_order = _sort_units_by_speed()
	for unit in action_order:
		await unit.turn_start()

	CombatSystem.combat_turn_started.push(self)

## 开始行动
func action_start() -> void:
	if not is_combat_active:
		return
	# 取出下一个行动的角色
	_current_action_unit = action_order.pop_front()
	await _current_action_unit.action_start(player_combats, enemy_combats)

## 执行行动
func action_execute() -> void:
	if not is_combat_active:
		return
	await _current_action_unit.action()
	CombatSystem.combat_action_executed.push(_current_action_unit)

## 结束行动
func action_end() -> void:
	if not is_combat_active:
		return
	await _current_action_unit.action_end()
	CombatSystem.combat_action_ended.push(_current_action_unit)

## 结束回合
func turn_end() -> void:
	if not is_combat_active:
		return
	_current_action_unit = null
	action_order.clear()
	CombatSystem.combat_turn_ended.push(self)

## 结束战斗
func end_combat() -> void:
	if not is_combat_active:
		return	
	is_combat_active = false
	
	# 通知所有单位战斗结束
	for unit in player_combats + enemy_combats:
		await unit.combat_end()
	CombatSystem.combat_end.push(self)

## 获取目标
func get_valid_targets(unit: CombatComponent, target_type: String) -> Array[CombatComponent]:
	var targets: Array[CombatComponent] = []
	
	match target_type:
		"self":
			targets.append(unit)
		"ally":
			targets = get_all_allies(unit)
		"enemy":
			targets = get_all_enemies(unit)
		"all":
			targets = get_all_allies(unit) + get_all_enemies(unit)
	
	# 过滤掉死亡单位
	targets = targets.filter(func(target): return target.is_alive)
	
	return targets

## 获取所有敌人
func get_all_enemies(unit: CombatComponent) -> Array[CombatComponent]:
	if unit.combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER:
		return enemy_combats
	return player_combats

## 获取所有盟友
func get_all_allies(unit: CombatComponent) -> Array[CombatComponent]:
	if unit.combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER:
		return player_combats
	return enemy_combats

## 是否达到最大回合数
func is_max_turn_count_reached() -> bool:
	return current_turn >= _combat_config.max_turn_count

## 是否全部执行完毕
func is_all_units_executed() -> bool:
	return action_order.is_empty()

func check_victory_condition() -> bool:
	for enemy : CombatComponent in enemy_combats:
		if enemy.is_alive:
			return false
	return true

func check_defeat_condition() -> bool:
	for player : CombatComponent in player_combats:
		if player.is_alive:
			return false
	return true

## 战斗胜利
func combat_victory() -> void:
	pass

## 战斗失败
func combat_defeat() -> void:
	pass

## 角色行动顺序排序
func _sort_units_by_speed() -> Array[CombatComponent]:
	var order : Array[CombatComponent] = player_combats + enemy_combats
	order.shuffle()
	order.sort_custom(func(a, b): return a.speed > b.speed)
	return order
