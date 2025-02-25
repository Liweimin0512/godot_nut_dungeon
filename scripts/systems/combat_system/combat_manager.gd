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
var players: Array[Node] = []
## 敌人单位
var enemies: Array[Node] = []
## 角色行动顺序
var action_order: Array[Node] = []
## 战斗数据配置
var _combat_config : CombatModel

## 当前行动的角色
var _current_action_unit : Node


func _init(combat_info: CombatModel, p_players: Array[Node], p_enemies: Array[Node]) -> void:
	_combat_config = combat_info
	players = p_players
	enemies = p_enemies


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
	for unit in players + enemies:
		var component := _get_combat_component(unit)
		component.combat_start()

	CombatSystem.combat_started.push(self)

## 开始新回合
func start_turn() -> void:
	if not is_combat_active:
		return
	current_turn += 1
	action_order = _sort_units_by_speed()
	for unit in action_order:
		var component := _get_combat_component(unit)
		component.turn_start()

	CombatSystem.combat_turn_started.push(self)

## 开始行动
func action_start() -> void:
	if not is_combat_active:
		return
	# 取出下一个行动的角色
	_current_action_unit = action_order.pop_front()
	var component := _get_combat_component(_current_action_unit)

	# 如果是自动战斗或者是敌方单位，自动选择技能和目标
	if _is_auto_action():
		component.action_start()
		if component.current_action:
			CombatSystem.combat_action_started.push([_current_action_unit, component.current_action])
	else:
		# 非自动战斗且是玩家控制角色，等待玩家输入
		CombatSystem.combat_action_selecting.push(_current_action_unit)


## 是否自动行动
## [return] 如果是自动行动，则返回 true
func _is_auto_action() -> bool:
	if is_auto:
		return true
	var component := _get_combat_component(_current_action_unit)
	if component._combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.ENEMY:
		return true
	return false


## 执行行动
func action_execute() -> void:
	if not is_combat_active:
		return
	var component : CombatComponent = CombatSystem.get_combat_component(_current_action_unit)
	var current_action: CombatAction = component.current_action
	CombatSystem.combat_action_executing.push(current_action)
	await component.action_execute()
	CombatSystem.combat_action_executed.push(current_action)


## 结束行动
func action_end() -> void:
	if not is_combat_active:
		return
	var component : CombatComponent = _get_combat_component(_current_action_unit)
	component.action_end()
	CombatSystem.combat_action_ended.push(component.current_action)


## 结束回合
func end_turn() -> void:
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
	for unit in players + enemies:
		var component = _get_combat_component(unit)
		component.combat_end()
	CombatSystem.combat_end.push(self)


## 是否达到最大回合数
## [return] 如果已达到最大回合数，则返回 true
func is_max_turn_count_reached() -> bool:
	return current_turn >= _combat_config.max_turn_count


## 是否全部执行完毕
## [return] 如果没有单位在行动，则返回 true
func is_all_units_executed() -> bool:
	return action_order.is_empty()


## 检查敌方是否全部死亡
## [return] 如果敌方全部死亡，则返回 true
func check_victory_condition() -> bool:
	for enemy in enemies:
		var component := _get_combat_component(enemy)
		if component.is_alive:
			return false
	return true


## 检查玩家是否全部死亡
## [return] 如果玩家全部死亡，则返回 true
func check_defeat_condition() -> bool:
	for player in players:
		var component := _get_combat_component(player)
		if component.is_alive:
			return false
	return true


## 战斗胜利
func combat_victory() -> void:
	print("combat_victory")


## 战斗失败
func combat_defeat() -> void:
	print("combat_defeat")


func select_action_target(target : Node) -> void:
	var component: CombatComponent = _get_combat_component(_current_action_unit)
	component.current_action.targets = [target]


## 获取所有敌方单位
func get_enemy_units(caster : Node) -> Array[Node]:
	var caster_component : CombatComponent = _get_combat_component(caster)
	if caster_component.get_camp() == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER:
		return enemies
	return players


## 获取所有友方单位
func get_ally_units(caster : Node) -> Array[Node]:
	var caster_component : CombatComponent = _get_combat_component(caster)
	if caster_component.get_camp() == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER:
		return players
	return enemies


# 内部函数


## 角色行动顺序排序
func _sort_units_by_speed() -> Array[Node]:
	var order : Array[Node] = players + enemies
	order.shuffle()
	order.sort_custom(
		func(a, b): 
			var a_combat := _get_combat_component(a)
			var b_combat := _get_combat_component(b)
			return a_combat.speed > b_combat.speed
			)
	return order
	

func _get_combat_component(unit: Node) -> CombatComponent:
	return CombatSystem.get_combat_component(unit)
