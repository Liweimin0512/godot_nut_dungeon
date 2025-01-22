extends UIViewManager
class_name UIWidgetManager

## 创建Widget
func create_widget(id: StringName, parent: Node = null, data: Dictionary = {}) -> Control:
	# 1. 尝试从对象池获取可重用的widget
	var widget_type = get_view_type(id)
	if widget_type and widget_type.reusable:
		var cached_widget = UIManager.resource_manager.get_instance(id) as Control
		if cached_widget:
			if parent:
				parent.add_child(cached_widget)
			var component = UIManager.get_widget_component(cached_widget)
			if component:
				component.initialize(data)
			return cached_widget
	
	# 2. 如果没有可重用的widget，创建新的
	var widget = super.create_view(id, parent, data) as Control
	if not widget:
		return null
	
	var component = UIManager.get_widget_component(widget)
	if not component:
		push_error("Widget component not found: %s" % id)
		widget.queue_free()
		return null
	
	return widget

## 回收Widget
func recycle_widget(widget: Control) -> void:
	if not widget:
		return
	
	var component = UIManager.get_widget_component(widget)
	if not component:
		widget.queue_free()
		return
	
	if component.reusable:
		# 1. 从父节点移除
		if widget.get_parent():
			widget.get_parent().remove_child(widget)
		
		# 2. 重置组件状态
		component.recycle()
		
		# 3. 缓存到对象池
		UIManager.resource_manager.recycle_instance(component.widget_type.ID, widget)
	else:
		destroy_view(widget)

## 批量创建Widget
func create_widgets(id: StringName, parent: Node, data_list: Array) -> Array[Control]:
	var widgets: Array[Control] = []
	for item_data in data_list:
		var widget = create_widget(id, parent, item_data)
		if widget:
			widgets.append(widget)
	return widgets

## 批量回收Widget
func recycle_widgets(widgets: Array) -> void:
	for widget in widgets:
		if widget is Control:
			recycle_widget(widget)

## 注册Widget类型
func register_widget_type(widget_type: UIWidgetType) -> void:
	super.register_view_type(widget_type)
