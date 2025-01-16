extends Control

"""
管理和协调所有UI元素和UI界面。
提供方法来打开、关闭、或切换UI窗口。
可能还需要管理UI资源和配置，以及处理UI相关的事件和输入。
"""
## 界面分组
var _group: Dictionary = {}
## 界面数据
var _ui_types : Dictionary = {}

#region 分组相关

## 设置分组
func set_group(group_name : StringName, control: Node) -> void:
	_group[group_name] = control

## 获取分组
func get_group(group_name : StringName) -> Node:
	#if not _group.has(group_name): return null
	assert(_group.has(group_name), "不是有效的UI组")
	return _group[group_name]

## 移除分组
func remove_group(group_name: StringName) -> bool:
	return _group.erase(group_name)

## 判断是否存在分组
func has_group(group_name : StringName) -> bool:
	return _group.has(group_name)

#endregion

## 加载界面数据
func load_model(model: UIType) -> void:
	_ui_types[model.ID] = model

## 获取数据模型
func _get_type(ID : StringName) -> UIType:
	return _ui_types[ID]

## 创建界面
func create_interface(ID: StringName, data: Dictionary = {}) -> Control:
	if not _ui_types.has(ID) : return null
	var _model : UIType = _get_type(ID)
	assert(_model.scene, "UI场景文件无效！！！")
	var interface: Control = _model.scene.instantiate()
	if is_widget(interface):
		interface.set("_widget_type", _model)
	#interface._create(data)
	#interface.call("_create", data)
	create_widget(interface, data)
	return interface

## 获取控件，返回值为null则表示控件不存在
func get_interface(ID : StringName) -> Control:
	var _model : UIType = _get_type(ID)
	var _group: UIGroup = get_group(_model.groupID)
	return _group.get_interface(ID)

## 获取所有界面
func get_all_interface(groupID: StringName) -> Array:
	var _group: UIGroup = get_group(groupID)
	return _group.get_all_interface()

## 获取当前界面
func get_current_interface(groupID : StringName) -> Control:
	var _group: UIGroup = get_group(groupID)
	return _group.get_current_interface()

## 开启界面
func open_interface(ID : StringName, data : Dictionary = {}) -> Control:
	var _model : UIType = _get_type(ID)
	var _group: UIGroup = get_group(_model.groupID)
	var _form: Control = _group.get_interface(ID)
	if not is_instance_valid(_form): 
		_form = create_interface(ID, data)
	await _group.open_interface(_form, data)
	open_widget(_form, data)
	return _form
	
## 关闭界面
func close_interface(ID : StringName) -> void:
	var _model : UIType = _get_type(ID)
	var _group: UIGroup = get_group(_model.groupID)
	var _form: Control = _group.get_interface(ID)
	if is_instance_valid(_form): 
		await _group.close_interface(_form)

## 关闭当前界面
func close_current_interface(groupID : StringName, reenter : bool = true) -> void:
	var _group: UIGroup = get_group(groupID)
	if _group.get_child_count() <= 0 : return
	await _group.close_current()

## 关闭所有界面
func close_all(groupID : StringName) -> void:
	var _group: UIGroup = get_group(groupID)
	await _group.close_all()

#region widget相关

## 是否是widget
func is_widget(widget: Control) -> bool:
	#return widget.has("_widget_type")
	return widget.get("widget_name") != null

## 创建widget
func create_widget(widget: Control, data: Dictionary = {}) -> void:
	for c in widget.get_children():
		if c is Control: create_widget(c, data)
	if widget.has_method("_create"):
		widget.call("_create", data)

## 开启Widget
func open_widget(widget: Control, data: Dictionary = {}) -> void:
	if is_widget(widget) and widget.has_method("_open"):
		widget.call("_open", data)
	for c in widget.get_children():
		if c is Control: open_widget(c, data)

## 更新UI
func update_widget(widget: Control, data: Dictionary = {}) -> void:
	if is_widget(widget) and widget.has_method("_update"): 
		widget.call("_update", data)
	for c in widget.get_children():
		if c is Control: update_widget(c, data)

## 关闭widget
func close_widget(widget: Control) -> void:
	for c in widget.get_children():
		if c is Control: await close_widget(c)
	if is_widget(widget) and widget.has_method("_close"): 
		#await widget.call("_close")
		await widget._close()

#endregion
