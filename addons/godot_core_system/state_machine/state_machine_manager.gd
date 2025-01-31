extends Node
class_name StateMachineManager

## 状态机管理器

## 信号
signal state_machine_registered(id: StringName)
signal state_machine_unregistered(id: StringName)
signal state_machine_started(id: StringName)
signal state_machine_stopped(id: StringName)

## 存储所有状态机的字典
var _state_machines: Dictionary = {}

## 单例实例
static var instance: StateMachineManager = null

func _init() -> void:
	assert(instance == null, "状态机管理器是单例，不能创建多个实例")
	instance = self

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		instance = null

## 注册状态机
func register_state_machine(id: StringName, state_machine: BaseStateMachine) -> void:
	if _state_machines.has(id):
		push_warning("状态机 %s 已经注册" % id)
		return
	
	_state_machines[id] = state_machine
	state_machine_registered.emit(id)

## 取消注册状态机
func unregister_state_machine(id: StringName) -> void:
	if not _state_machines.has(id):
		return
	
	var state_machine = _state_machines[id]
	if state_machine.is_active:
		state_machine.stop()
	
	_state_machines.erase(id)
	state_machine_unregistered.emit(id)

## 获取状态机
func get_state_machine(id: StringName) -> BaseStateMachine:
	return _state_machines.get(id)

## 启动状态机
func start_state_machine(id: StringName, initial_state: StringName = &"", msg: Dictionary = {}) -> void:
	var state_machine = get_state_machine(id)
	if not state_machine:
		push_error("状态机 %s 不存在" % id)
		return
	
	state_machine.start(initial_state, msg)
	state_machine_started.emit(id)

## 停止状态机
func stop_state_machine(id: StringName) -> void:
	var state_machine = get_state_machine(id)
	if not state_machine:
		push_error("状态机 %s 不存在" % id)
		return
	
	state_machine.stop()
	state_machine_stopped.emit(id)

## 获取所有状态机
func get_all_state_machines() -> Array[BaseStateMachine]:
	return _state_machines.values()

## 获取所有状态机ID
func get_all_state_machine_ids() -> Array[StringName]:
	return _state_machines.keys()

## 清除所有状态机
func clear_state_machines() -> void:
	for id in _state_machines.keys():
		unregister_state_machine(id)

## 处理事件
func handle_event(event_name: StringName, args: Array = []) -> void:
	for state_machine in _state_machines.values():
		if state_machine.is_active:
			state_machine.handle_event(event_name, args)
