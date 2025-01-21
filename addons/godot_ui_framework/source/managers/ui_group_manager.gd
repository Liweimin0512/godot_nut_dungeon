extends RefCounted
class_name UIGroupManager

## UI组管理器，负责管理UI组的生命周期和状态

signal interface_opened(interface: Control)
signal interface_closed(interface: Control)
signal interface_focused(interface: Control)
signal modal_pushed(interface: Control)
signal modal_popped(interface: Control)

## 显示UI
func show_ui(ui: Control, data: Dictionary = {}, hide_other:bool = true) -> void:
	# 如果栈不为空，处理当前UI
	var current = get_current_ui()
	if current and hide_other:
		# 可以隐藏或暂停当前UI
		current.visible = false
	# 将新的UI界面压入栈中
	_ui_stack.push(ui)
	root.add_child(ui, true)

	# 初始化新UI
	if ui.has_method("_create"):
		ui._create(data)

## 隐藏UI
func hide_ui(ui: Control) -> void:
	if _ui_stack.is_empty(): return

	# 如果关闭的不是栈顶UI，可能需要特殊处理
	if ui != get_current_ui():
		push_warning("Attempting to close a UI that is not at the top of the stack")
		return
	# 弹出并移除当前UI
	var popped = _ui_stack.pop()
	root.remove_child(popped)
	# 恢复之前的UI
	var previous = get_current_ui()
	if previous:
		previous.visible = true

## 关闭所有UI
func close_all(group_name: StringName) -> void:
	var group = get_group(group_name)
	if not group:
		push_error("UI组不存在:%s" % group_name)
		return
	while not group._ui_stack.is_empty():
		var ui = group._ui_stack.pop()
		group.root.remove_child(ui)
	group._ui_stack.clear()

## 获取当前界面
func get_current_ui(group_name: StringName) -> Control:
	var group = get_group(group_name)
	if not group:
		push_error("UI组不存在:%s" % group_name)
		return null
	return group.get_current_ui()
