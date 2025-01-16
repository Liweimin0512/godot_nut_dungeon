extends Node
class_name UIGroup

@export var group_name : StringName = ""
var _current: Control:
	get:
		if get_child_count() <= 0 :return null
		return get_child(-1)

signal interface_opened
signal interface_closed

func _enter_tree() -> void:
	UIManager.set_group(group_name, self)

func _exit_tree() -> void:
	if UIManager.get_group(group_name) != self: return
	UIManager.remove_group(group_name)

## 开启界面
func open_interface(form: Control, data : Dictionary = {}, hide_all: bool = true) -> void:
	if form == get_current_interface(): return
	if hide_all: get_all_interface().map(func(form: Control): form.hide())
	if has_interface(form): form.move_to_front()
	else: add_child(form)
	form.show()
	interface_opened.emit()

## 关闭当前界面
func close_current() -> void:
	# 如果没有其他界面，直接返回
	if get_child_count() <= 0 : return
	var _current : Control = get_current_interface()
	await close_interface(_current)
	if get_child_count() > 0:
		open_interface(get_child(-1))
	
## 关闭所有界面
func close_all() -> void:
	for index: int in range(get_all_interface().size(), 0, -1): 
		var child : Control = get_child(index - 1)
		await close_interface(child)

## 关闭界面, 注意：这会移除释放相关界面
func close_interface(form: Control) -> void:
	if not has_interface(form) : return
	await UIManager.close_widget(form)
	# 如果是当前界面，按关闭当前界面逻辑处理
	remove_child(form)
	form.queue_free()
	interface_closed.emit()

## 获取界面，返回值为null则表示控件不存在
func get_interface(ID : StringName) -> Control:
	var forms : Array = get_children()
	var filters : Array = forms.filter(func(form: Control): return _get_widget_name(form) == ID)
	if filters.is_empty() : return null
	return filters[0]

## 获取所有界面
func get_all_interface() -> Array:
	return get_children()

## 获取当前界面
func get_current_interface() -> Control:
	#if not has_current(): return null
	#return get_child(-1)
	return _current

## 是否存在当前界面
func has_current() -> bool:
	return get_child_count() > 0

## 是否存在界面
func has_interface(form : Control) -> bool:
	if not is_instance_valid(form) or not UIManager.is_widget(form): return false
	var _widget_name := _get_widget_name(form)
	var filter: Control = get_interface(_widget_name)
	return is_instance_valid(filter)

func _get_widget_name(widget: Control) -> String:
	if widget.get("widget_type") != null : 
		return widget.get("widget_type").ID
	elif not UIManager.is_widget(widget) : return ""
	else: 
		return widget.widget_name
