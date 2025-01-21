extends RefCounted
class_name UIWidgetManager

## 控件缓存池
var _widget_pools: Dictionary[StringName, Array] = {}
## 控件数据
var _widget_types: Dictionary[StringName, UIWidgetType] = {}

## 注册控件数据
func register_widget_type(widget_type: UIWidgetType) -> void:
	_widget_types[widget_type.ID] = widget_type
	_widget_pools[widget_type.ID] = []

## 卸载控件数据
func unregister_widget_type(widget_id: StringName) -> void:
	_widget_types.erase(widget_id)
	for widget in _widget_pools[widget_id]:
		widget.queue_free()
	_widget_pools.erase(widget_id)

## 获取控件数据
func get_widget_type(widget_id: StringName) -> UIWidgetType:
	return _widget_types[widget_id]

## 创建控件实例
func create_widget(widget_id: StringName, parent: Node, data: Dictionary = {}) -> Control:
	var widget: Control
	
	# 尝试从对象池获取
	if not _widget_pools[widget_id].is_empty():
		widget = _widget_pools[widget_id].pop_back()
	else:
		# 实例化新控件
		var scene = _widget_types[widget_id].scene
		widget = scene.instantiate()
		
	# 添加到父节点
	parent.add_child(widget)
	# 初始化控件
	var widget_component: UIWidgetComponent = widget.get_node("WidgetComponent")
	widget_component.initialize(data)
	return widget

## 回收控件到对象池
func recycle_widget(widget_id: StringName, widget: Control) -> void:
	if not widget:return
	
	widget.get_parent().remove_child(widget)
	_widget_pools[widget_id].append(widget)
