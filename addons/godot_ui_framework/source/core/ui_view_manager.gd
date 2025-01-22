extends RefCounted
class_name UIViewManager

## 视图类型注册表
var _view_types: Dictionary[StringName, UIViewType] = {}

## 注册视图类型
func register_view_type(view_type: UIViewType) -> void:
	if _view_types.has(view_type.ID):
		push_warning("View type already registered: %s" % view_type.ID)
		return
		
	_view_types[view_type.ID] = view_type
	
	# 处理预加载
	if view_type.preload_mode == UIViewType.PRELOAD_MODE.PRELOAD:
		UIManager.resource_manager.load_scene(
			view_type.scene_path, 
			UIResourceManager.LoadMode.IMMEDIATE
		)
	elif view_type.preload_mode == UIViewType.PRELOAD_MODE.LAZY_LOAD:
		UIManager.resource_manager.load_scene(
			view_type.scene_path, 
			UIResourceManager.LoadMode.LAZY
		)

## 注销视图类型
func unregister_view_type(id: StringName) -> void:
	if not _view_types.has(id):
		push_warning("View type not registered: %s" % id)
		return
		
	var view_type = _view_types[id]
	UIManager.resource_manager.clear_cache(view_type.scene_path)
	_view_types.erase(id)

## 获取视图类型
func get_view_type(id: StringName) -> UIViewType:
	return _view_types.get(id)

## 创建视图实例
func create_view(id: StringName, parent: Node, data: Dictionary = {}) -> Control:
	var view_type = get_view_type(id)
	if not view_type:
		push_error("View type not found: %s" % id)
		return null
	
	var view = UIManager.resource_manager.get_instance(
		view_type.scene_path,
		view_type.scene_path,
		view_type.cache_mode == UIViewType.CACHE_MODE.CACHE_IN_MEMORY
	)
	
	if not view:
		return null
	
	if parent:
		parent.add_child(view)
	
	var component : UIViewComponent
	if UIManager.is_scene(view):
		component = UIManager.get_scene_component(view)
	elif UIManager.is_widget(view):
		component = UIManager.get_widget_component(view)
	if component:
		component.initialize(data)
	else:
		push_error("can not found view component in node: {0}".format([view]))
	
	return view

## 销毁视图
func destroy_view(view: Control) -> void:
	var component = UIManager.get_view_component(view)
	if component:
		component.dispose()
