extends Node
class_name UIGroup

## 组名称
@export var group_name: StringName = ""
## 组ROOT节点
@export var root: Control = null
## 默认过渡动画
@export var default_transition: UITransition
## 是否启用模态窗口
@export var enable_modal: bool = true

## 当前界面
var _current: Control:
	get:
		if get_child_count() <= 0: return null
		return get_child(-1)
## 层级管理
var _layer_order: Dictionary = {}
## 模态窗口栈
var _modal_stack: Array[Control] = []
## 活动过渡动画
var _active_transitions: Array[UITransition] = []
## UI栈
var _ui_stack: Stack = Stack.new()

## 信号
signal interface_opened(interface: Control)
signal interface_closed(interface: Control)
signal interface_focused(interface: Control)
signal modal_pushed(interface: Control)
signal modal_popped(interface: Control)

## 开启界面
func open_interface(form: Control, data: Dictionary = {}, hide_all: bool = true) -> void:
	if not is_instance_valid(form): return
	if form == get_current_interface(): return
	
	# 获取UI类型
	var ui_type = _get_ui_type(form)
	if not ui_type: return
	
	# 处理层级
	var layer = ui_type.layer
	_update_layer_order(form, layer)
	
	# 隐藏其他界面
	if hide_all and ui_type.hide_others:
		get_all_interface().map(func(form: Control): form.hide())
	
	# 添加到场景树
	if not has_interface(form):
		add_child(form)
		_sort_children_by_layer()
	else:
		form.move_to_front()
	
	# 应用过渡动画
	var transition = ui_type.transition if ui_type.transition else default_transition
	if transition:
		_active_transitions.append(transition)
		transition.apply_open_transition(form)
		await get_tree().create_timer(transition.duration).timeout
		_active_transitions.erase(transition)
	
	form.show()
	
	# 处理模态窗口
	if enable_modal and ui_type.is_modal:
		_push_modal(form)
	
	interface_opened.emit(form)
	interface_focused.emit(form)

## 关闭当前界面
func close_current() -> void:
	if get_child_count() <= 0: return
	var current = get_current_interface()
	await close_interface(current)
	if get_child_count() > 0:
		var next = get_child(-1)
		open_interface(next)
		interface_focused.emit(next)

## 关闭所有界面
#func close_all() -> void:
	#for index in range(get_all_interface().size(), 0, -1):
		#var child = get_child(index - 1)
		#await close_interface(child)

## 关闭界面
func close_interface(form: Control) -> void:
	if not has_interface(form): return
	
	# 获取UI类型
	var ui_type = _get_ui_type(form)
	if not ui_type: return
	
	# 处理模态窗口
	if enable_modal and form in _modal_stack:
		_pop_modal(form)
	
	# 应用过渡动画
	var transition = ui_type.transition if ui_type.transition else default_transition
	if transition:
		_active_transitions.append(transition)
		transition.apply_close_transition(form)
		await get_tree().create_timer(transition.duration).timeout
		_active_transitions.erase(transition)
	
	# 从场景树移除
	remove_child(form)
	_layer_order.erase(form)
	
	interface_closed.emit(form)

## 获取界面
func get_interface(ID: StringName) -> Control:
	var forms = get_children()
	var filters = forms.filter(func(form: Control): return _get_widget_name(form) == ID)
	if filters.is_empty(): return null
	return filters[0]

## 获取所有界面
func get_all_interface() -> Array:
	return get_children()

## 获取当前界面
func get_current_interface() -> Control:
	return _current

## 是否存在当前界面
func has_current() -> bool:
	return get_child_count() > 0

## 是否存在界面
func has_interface(form: Control) -> bool:
	if not is_instance_valid(form) or not UIManager.is_widget(form): return false
	var widget_name = _get_widget_name(form)
	var filter = get_interface(widget_name)
	return is_instance_valid(filter)

## 更新层级顺序
func _update_layer_order(form: Control, layer: int) -> void:
	_layer_order[form] = layer
	_sort_children_by_layer()

## 根据层级排序子节点
func _sort_children_by_layer() -> void:
	var children = get_children()
	children.sort_custom(func(a: Control, b: Control) -> bool:
		var a_layer = _layer_order.get(a, 0)
		var b_layer = _layer_order.get(b, 0)
		return a_layer < b_layer
	)
	
	for i in range(children.size()):
		move_child(children[i], i)

## 推入模态窗口
func _push_modal(form: Control) -> void:
	if form in _modal_stack: return
	_modal_stack.append(form)
	modal_pushed.emit(form)
	
	# 禁用其他窗口的输入
	for other in get_children():
		if other != form and other is Control:
			other.mouse_filter = Control.MOUSE_FILTER_IGNORE

## 弹出模态窗口
func _pop_modal(form: Control) -> void:
	if not form in _modal_stack: return
	_modal_stack.erase(form)
	modal_popped.emit(form)
	
	# 如果还有其他模态窗口，保持其他窗口禁用
	# 否则启用所有窗口的输入
	if _modal_stack.is_empty():
		for other in get_children():
			if other is Control:
				other.mouse_filter = Control.MOUSE_FILTER_STOP

## 获取界面名称
func _get_widget_name(widget: Control) -> String:
	if widget.get("widget_type") != null:
		return widget.get("widget_type").ID
	elif not UIManager.is_widget(widget):
		return ""
	else:
		return widget.widget_name

## 获取UI类型
func _get_ui_type(form: Control) -> UIType:
	if not form.get("widget_type"):
		return null
	return form.get("widget_type")
