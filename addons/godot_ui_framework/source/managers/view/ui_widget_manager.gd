extends UIViewManager
class_name UIWidgetManager

## 创建Widget
func create_widget(id: StringName, parent: Node = null, data: Dictionary = {}) -> Control:
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
		component.recycle()
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
