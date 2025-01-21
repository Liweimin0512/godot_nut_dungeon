extends RefCounted
class_name UIFormManager

## 注册UI表单
func register_form(form_type: UIFormType) -> void:
	UIManager.widget_manager.register_widget_type(form_type)

## 卸载UI表单
func unregister_form(ID: StringName) -> void:
	UIManager.widget_manager.unregister_widget_type(ID)

## 获取UI表单
func get_form(ID: StringName) -> UIFormType:
	return UIManager.widget_manager.get_widget_type(ID)

## 创建界面
func instantiate_ui(ID: StringName, data: Dictionary = {}) -> Control:
	if not _ui_types.has(ID):
		push_error("UI类型不存在：%s" % ID)
		return null
		
	var ui_type := _get_type(ID)
	var interface := _resource_manager.get_ui_instance(ui_type)
	if not interface:
		return null
		
	# 设置初始状态
	_ui_states[ID] = UIState.NONE
	
	# 初始化界面数据
	if interface.has_method("_create"):
		interface._create(data)
		
	return interface

## 获取控件
func get_ui(ID: StringName) -> Control:
	var ui_type := _get_type(ID)
	var group := get_group(ui_type.groupID)
	return group.get_ui(ID)

## 获取所有界面
func get_all_ui(groupID: StringName) -> Array:
	var group := get_group(groupID)
	return group.get_all_ui()

## 获取当前界面
func get_current_ui(groupID: StringName) -> Control:
	var group := get_group(groupID)
	return group.get_current_ui()

## 打开界面
func show_ui(ID: StringName, data: Dictionary = {}) -> Control:
	var ui_type := _get_type(ID)
	var group := get_group(ui_type.groupID)
	
	# 更新状态
	_ui_states[ID] = UIState.OPENING
	ui_state_changed.emit(ID, UIState.OPENING)
	
	# 获取或创建界面实例
	var interface := get_ui(ID)
	if not is_instance_valid(interface):
		interface = instantiate_ui(ID, data)
		if not interface:
			return null
	
	# 处理过渡动画
	if ui_type.transition:
		ui_transition_started.emit(ID)
		await group.show_ui(interface, data)
		ui_transition_completed.emit(ID)
	else:
		await group.show_ui(interface, data)
	
	# 更新状态
	_ui_states[ID] = UIState.OPENED
	ui_state_changed.emit(ID, UIState.OPENED)
	
	# 更新导航历史
	_update_navigation_history(ui_type.groupID, ID)
	
	return interface

## 关闭界面
func hide_ui(ID: StringName) -> void:
	var ui_type := _get_type(ID)
	var group := get_group(ui_type.groupID)
	var interface := get_ui(ID)
	
	if not is_instance_valid(interface):
		return
		
	# 更新状态
	_ui_states[ID] = UIState.CLOSING
	ui_state_changed.emit(ID, UIState.CLOSING)
	
	# 处理过渡动画
	if ui_type.transition:
		ui_transition_started.emit(ID)
		await group.hide_ui(interface)
		ui_transition_completed.emit(ID)
	else:
		await group.hide_ui(interface)
	
	# 根据缓存策略处理实例
	if ui_type.cache_mode == UIType.CACHE_MODE.DESTROY_ON_CLOSE:
		_resource_manager.unload_ui(ui_type)
	
	# 更新状态
	_ui_states[ID] = UIState.CLOSED
	ui_state_changed.emit(ID, UIState.CLOSED)

## 关闭当前界面
func close_current_ui(groupID: StringName) -> void:
	var group := get_group(groupID)
	if group.get_child_count() <= 0:
		return
	await group.close_current()

## 关闭所有界面
func close_all_ui(groupID: StringName) -> void:
	var group := get_group(groupID)
	await group.close_all_ui()
