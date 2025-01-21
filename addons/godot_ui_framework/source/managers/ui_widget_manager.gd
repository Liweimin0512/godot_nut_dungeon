# ui_widget_manager.gd
extends RefCounted
class_name UIWidgetManager

## Widget类型注册表
var _widget_types: Dictionary[StringName, UIWidgetType] = {}

## 注册Widget类型
func register_widget_type(widget_type: UIWidgetType) -> void:
	if _widget_types.has(widget_type.ID):
		push_warning("Widget type already registered: %s" % widget_type.ID)
		return
		
	_widget_types[widget_type.ID] = widget_type
	
	# 处理预加载
	if widget_type.preload_mode == UIWidgetType.PRELOAD_MODE.PRELOAD:
		UIManager.resource_manager.load_scene(
			widget_type.scene_path, 
			UIResourceManager.LoadMode.IMMEDIATE
		)
	elif widget_type.preload_mode == UIWidgetType.PRELOAD_MODE.LAZY_LOAD:
		UIManager.resource_manager.load_scene(
			widget_type.scene_path, 
			UIResourceManager.LoadMode.LAZY
		)

## 注销Widget类型
func unregister_widget_type(id: StringName) -> void:
	if not _widget_types.has(id):
		push_warning("Widget type not registered: %s" % id)
		return
		
	var widget_type = _widget_types[id]
	# 清理相关资源
	UIManager.resource_manager.clear_cache(widget_type.scene_path)
	_widget_types.erase(id)

## 获取Widget类型
func get_widget_type(id: StringName) -> UIWidgetType:
	if not _widget_types.has(id):
		push_error("Widget type not found: %s" % id)
		return null
	return _widget_types[id]

## 创建Widget实例
func create_widget(id: StringName, parent: Node = null, data: Dictionary = {}) -> Control:
	var widget_type = get_widget_type(id)
	if not widget_type:
		return null
	
	# 根据缓存策略决定是否使用对象池
	var use_pool = widget_type.cache_mode == UIWidgetType.CACHE_MODE.CACHE_IN_MEMORY
	
	# 获取实例
	var widget = UIManager.resource_manager.get_scene_instance(
		widget_type.scene_path,
		use_pool
	)
	
	if not widget:
		return null
	
	# 添加到父节点
	if parent:
		parent.add_child(widget)
	
	# 初始化Widget
	var component = UIManager.get_widget_component(widget)
	if component:
		component.initialize(data)
	elif widget.has_method("_setup"):
		widget._setup(data)
	
	return widget

## 回收Widget实例
func recycle_widget(id: StringName, widget: Control) -> void:
	var widget_type = get_widget_type(id)
	if not widget_type:
		widget.queue_free()
		return
	
	# 调用清理方法
	var component = UIManager.get_widget_component(widget)
	if component:
		component.dispose()
	elif widget.has_method("_cleanup"):
		widget._cleanup()
	
	# 根据缓存策略处理实例
	match widget_type.cache_mode:
		UIWidgetType.CACHE_MODE.CACHE_IN_MEMORY:
			UIManager.resource_manager.recycle_instance(widget_type.scene_path, widget)
		UIWidgetType.CACHE_MODE.DESTROY_ON_CLOSE:
			widget.queue_free()
		UIWidgetType.CACHE_MODE.SMART_CACHE:
			# 可以在这里添加更智能的缓存策略
			widget.queue_free()

## 批量创建Widget
func create_widgets(id: StringName, parent: Node, data_list: Array) -> Array[Control]:
	var widgets: Array[Control] = []
	for item_data in data_list:
		var widget = create_widget(id, parent, item_data)
		if widget:
			widgets.append(widget)
	return widgets

## 批量回收Widget
func recycle_widgets(id: StringName, widgets: Array) -> void:
	for widget in widgets:
		if widget is Control:
			recycle_widget(id, widget)

## 检查Widget类型是否已注册
func has_widget_type(id: StringName) -> bool:
	return _widget_types.has(id)

## 获取所有注册的Widget类型
func get_registered_types() -> Array[StringName]:
	return _widget_types.keys()
