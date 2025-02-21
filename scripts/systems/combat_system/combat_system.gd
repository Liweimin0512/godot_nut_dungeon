extends Node

## 战斗系统单例，负责管理战斗系统的初始化和战斗实例的生命周期

const COMBAT_STATE_MACHINE : StringName = &"combat"

## 战斗相关配置
const DEFAULT_COMBAT_CONFIG := {
	"max_turn_count": 99,
	"is_auto": true,
	"is_real_time": true
}

## 当前活跃的战斗管理器实例
var active_combat_manager: CombatManager
## 状态机管理器
var _state_machine_manager: CoreSystem.StateMachineManager:
	get:
		return CoreSystem.state_machine_manager
var _initialized : bool = false
var _combat_model_type : ModelType

# 事件注册
var combat_created : CombatEvent = CombatEvent.new(&"combat_created")						## 战斗创建事件
var combat_started : CombatEvent = CombatEvent.new(&"combat_started")						## 战斗开始事件
var combat_turn_started : CombatEvent = CombatEvent.new(&"combat_turn_started")				## 战斗回合开始事件
var combat_action_started : CombatEvent = CombatEvent.new(&"combat_action_started")			## 战斗动作开始事件
var combat_action_executing : CombatEvent = CombatEvent.new(&"combat_action_executing")		## 战斗动作执行开始事件
var combat_action_executed : CombatEvent = CombatEvent.new(&"combat_action_executed")		## 战斗动作执行事件
var combat_action_ended : CombatEvent = CombatEvent.new(&"combat_action_ended")				## 战斗动作结束事件
var combat_turn_executed : CombatEvent = CombatEvent.new(&"combat_turn_executed")			## 战斗回合执行事件
var combat_turn_ended : CombatEvent = CombatEvent.new(&"combat_turn_ended")					## 战斗回合结束事件
var combat_ended : CombatEvent = CombatEvent.new(&"combat_ended")							## 战斗结束事件
var action_ability_selected : CombatEvent = CombatEvent.new(&"action_ability_selected")		## 战斗动作技能选择事件
var action_target_set : CombatEvent = CombatEvent.new(&"action_target_set")					## 战斗动作目标设置事件

## 战斗相关信号
signal initialized(success: bool)

## 初始化战斗系统
func initialize(combat_model_type: ModelType) -> bool:
	if _initialized:
		return true
	# 初始化战斗相关的子系统
	# 例如：技能系统、效果系统、AI系统等
	_init_subsystems()

	# 检查依赖关系是否满足
	DataManager.load_model(combat_model_type,
		func(result: Variant):
			print(result)
			_initialized = true
			initialized.emit(_initialized)
	)
	_combat_model_type = combat_model_type
	return true

## 获取战斗配置
func get_combat_config(combat_id : StringName) -> CombatModel:
	return DataManager.get_data_model(_combat_model_type.model_name, combat_id)

## 创建新的战斗实例
func create_combat(
		combat_id : StringName,
		player_combats: Array[CombatComponent], 
		enemy_combats: Array[CombatComponent], 
		) -> CombatManager:
	# 如果已有活跃战斗，先结束它
	if active_combat_manager:
		end_combat()
	
	# 创建新的战斗管理器实例
	active_combat_manager = CombatManager.new(
		get_combat_config(combat_id),
		player_combats,
		enemy_combats
	)
	_state_machine_manager.register_state_machine(COMBAT_STATE_MACHINE, CombatStateMachine.new(), active_combat_manager)
	combat_created.push(active_combat_manager)
	return active_combat_manager

## 开始当前战斗
func start_combat() -> void:
	_state_machine_manager.start_state_machine(COMBAT_STATE_MACHINE, &"init")

## 结束当前战斗
func end_combat() -> void:
	if active_combat_manager:
		active_combat_manager.free()
		active_combat_manager = null
	_state_machine_manager.unregister_state_machine(COMBAT_STATE_MACHINE)	

## 获取当前战斗管理器实例
func get_active_combat() -> CombatManager:
	return active_combat_manager

## 初始化子系统
func _init_subsystems() -> void:
	# TODO: 初始化各个子系统
	pass

class CombatEvent:
	extends RefCounted

	var _event_name : StringName
	var _event_bus : CoreSystem.EventBus:
		get:
			return CoreSystem.event_bus

	func _init(p_event_name : StringName):
		_event_name = "CombatSystem." + p_event_name

	## 发送事件
	func push(payload : Variant = []) -> void:
		_event_bus.push_event(_event_name, payload)

	## 订阅事件
	func subscribe(callback : Callable) -> void:
		_event_bus.subscribe(_event_name, callback)
	
	## 取消订阅事件
	func unsubscribe(callback : Callable) -> void:
		_event_bus.unsubscribe(_event_name, callback)
