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

## 战斗相关信号
signal combat_created(combat_manager: CombatManager)
signal combat_started(combat_manager: CombatManager)
signal combat_ended(combat_manager: CombatManager)
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
	return true

## 创建新的战斗实例
func create_combat(
		player_combats: Array[CombatComponent],
		enemy_combats: Array[CombatComponent],
		combat_info: CombatModel) -> CombatManager:
	# 如果已有活跃战斗，先结束它
	if active_combat_manager:
		end_combat()
	
	# 创建新的战斗管理器实例
	active_combat_manager = CombatManager.new()
	# 连接信号
	_connect_combat_signals(active_combat_manager)
	active_combat_manager.player_combats = player_combats
	active_combat_manager.enemy_combats = enemy_combats
	_state_machine_manager.register_state_machine(COMBAT_STATE_MACHINE, CombatStateMachine.new(), active_combat_manager)
	
	combat_created.emit(active_combat_manager)
	return active_combat_manager

func start_combat(_combat_manager : CombatManager, combat_info : CombatModel) -> void:
	_state_machine_manager.start_state_machine(COMBAT_STATE_MACHINE, &"init", {"combat_info": combat_info})

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

## 连接战斗信号
func _connect_combat_signals(combat_manager: CombatManager) -> void:
	combat_manager.combat_started.connect(
		func(): combat_started.emit(combat_manager))
	combat_manager.combat_ended.connect(
		func(): combat_ended.emit(combat_manager))
