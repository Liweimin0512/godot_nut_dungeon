extends Node
class_name BaseStateMachine

signal state_changed(from_state: BaseState, to_state: BaseState)
signal event_triggered(event_name: StringName, args: Array)

## 当前状态
var current_state : BaseState = null
## 用于存储所有可用的状态
var states : Dictionary = {}

## 状态机代理
@export var agent : Node
## 判断状态机是否运行
var is_run : bool = false
## 状态机参数集合
var values : Dictionary = {}
## 历史状态栈
var state_history: Array[Dictionary] = []
## 父状态
var parent_state: BaseState = null

func _init(parent: BaseState = null) -> void:
	parent_state = parent

## 在节点的每一帧调用状态机当前状态的逐帧调用的方法
func _process(delta: float) -> void:
	if not is_run or not current_state: return
	current_state.update(delta)

## 在节点的每一物理帧调用状态机当前状态的逐物理帧调用的方法
func _physics_process(delta: float) -> void:
	if not is_run or not current_state: return
	current_state.physics_update(delta)

## 启动状态机
func launch(state_index : int = 0) -> void:
	assert(agent, '代理不能为空！')
	is_run = true
	transition_to(state_index)

## 添加状态
func add_state(state_type : int, state_class : GDScript) -> BaseState:
	var new_state = state_class.new(self, parent_state)
	states[state_type] = new_state
	return new_state

## 删除状态
func remove_state(state_type: int) -> void:
	if current_state == states.get(state_type):
		current_state = null
	states.erase(state_type)

## 切换状态
func transition_to(state_index: int, msg: Dictionary = {}) -> void:
	if not states.has(state_index):
		printerr("尝试切换到不存在的状态：", state_index)
		return
	
	var from_state = current_state
	if current_state:
		# 保存历史状态
		state_history.push_back({
			"state_index": state_index,
			"variables": values.duplicate()
		})
		current_state.exit()
	
	current_state = states[state_index]
	current_state.enter(msg)
	state_changed.emit(from_state, current_state)

## 返回上一个状态
func go_back(msg: Dictionary = {}) -> void:
	if state_history.is_empty():
		return
	
	var last_state = state_history.pop_back()
	values = last_state.variables
	transition_to(last_state.state_index, msg)

## 退出当前状态
func exit_current_state() -> void:
	if current_state:
		current_state.exit()
		current_state = null

## 处理事件
func handle_event(event_name: StringName, args: Array = []) -> void:
	event_triggered.emit(event_name, args)
	if current_state:
		current_state.handle_event(event_name, args)

## 根据名称设置属性的值
func set_variable(name : StringName, value : Variant) -> void:
	values[name] = value

## 根据名称获取属性的值
func get_variable(name: StringName) -> Variant:
	if values.has(name):
		return values[name]
	return null

## 是否存在属性
func has_variable(name: StringName) -> bool:
	return values.has(name)

## 获取当前状态索引
func get_current_state_index() -> int:
	for id in states:
		if states[id] == current_state:
			return id
	return -1

## 暂停状态机
func pause() -> void:
	is_run = false

## 恢复状态机
func resume() -> void:
	is_run = true
