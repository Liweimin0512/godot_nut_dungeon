extends RefCounted
class_name BaseState

## 当前状态所属的状态机
var state_machine = null
## 当前状态机所属的代理
var agent: Node = null :
	get:
		assert(state_machine and state_machine.agent, '状态机或代理不存在！')
		return state_machine.agent

## 父状态
var parent_state: BaseState = null
## 子状态机
var sub_machine: BaseStateMachine = null

## 构造函数：需求构造时候传入当前所属状态机
func _init(machine: BaseStateMachine, parent: BaseState = null) -> void:
	state_machine = machine
	parent_state = parent

## 虚方法：进入当前状态执行的操作
func enter(_msg : Dictionary = {}) -> void:
	pass

## 虚方法：退出当前状态执行的操作
func exit() -> void:
	if sub_machine:
		sub_machine.exit_current_state()

## 虚方法：当前状态下逐帧调用的方法
func update(delta : float) -> void:
	if sub_machine and sub_machine.is_run:
		sub_machine.process(delta)

## 虚方法：当前状态下逐物理帧调用的方法
func physics_update(delta : float) -> void:
	if sub_machine and sub_machine.is_run:
		sub_machine.physics_process(delta)

## 切换状态，这个方法调用状态机同名方法，提供方便
func transition_to(state_index: int, msg:Dictionary = {}) -> void:
	state_machine.transition_to(state_index, msg)

## 获取状态机参数
func get_fsm_variable(key) -> Variant:
	var value = state_machine.get_variable(key)
	if value == null and parent_state:
		return parent_state.get_fsm_variable(key)
	return value

## 设置状态机参数
func set_fsm_variable(key, value) -> void:
	state_machine.set_variable(key, value)

## 判断是否存在状态机参数
func has_fsm_variable(key) -> bool:
	return state_machine.has_variable(key) or (parent_state and parent_state.has_fsm_variable(key))

## 创建子状态机
func create_sub_machine() -> BaseStateMachine:
	sub_machine = BaseStateMachine.new()
	sub_machine.agent = agent
	return sub_machine

## 处理事件
func handle_event(event_name: StringName, args: Array = []) -> void:
	# 先让子状态机处理
	if sub_machine and sub_machine.is_run:
		sub_machine.handle_event(event_name, args)
	
	# 如果子状态机没有处理，调用自己的事件处理方法
	var method = "_on_" + event_name
	if has_method(method):
		callv(method, args)
	# 如果自己也没有处理，传递给父状态
	elif parent_state:
		parent_state.handle_event(event_name, args)
