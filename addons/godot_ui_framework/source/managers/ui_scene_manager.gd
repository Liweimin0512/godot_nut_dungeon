extends RefCounted
class_name UISceneManager

## 场景类型注册表
var _scene_types: Dictionary[StringName, UISceneType] = {}
## 分组场景栈
var _group_stacks: Dictionary[StringName, Stack] = {}

## 注册场景类型
func register_scene_type(scene_type: UISceneType) -> void:
	if _scene_types.has(scene_type.ID):
		push_warning("Scene type already registered: %s" % scene_type.ID)
		return
		
	_scene_types[scene_type.ID] = scene_type
	
	# 处理预加载
	if scene_type.preload_mode == UIViewType.PRELOAD_MODE.PRELOAD:
		UIManager.resource_manager.load_scene(
			scene_type.scene_path, 
			UIResourceManager.LoadMode.IMMEDIATE
		)
	elif scene_type.preload_mode == UIViewType.PRELOAD_MODE.LAZY_LOAD:
		UIManager.resource_manager.load_scene(
			scene_type.scene_path, 
			UIResourceManager.LoadMode.LAZY
		)

## 注销场景类型
func unregister_scene_type(id: StringName) -> void:
	if not _scene_types.has(id):
		push_warning("Scene type not registered: %s" % id)
		return
		
	var scene_type = _scene_types[id]
	# 清理相关资源
	UIManager.resource_manager.clear_cache(scene_type.scene_path)
	_scene_types.erase(id)

## 打开场景
func open_scene(id: StringName, group_name: StringName = "", data: Dictionary = {}) -> Control:
	var scene_type = _scene_types.get(id)
	if not scene_type:
		push_error("Scene type not found: %s" % id)
		return null
	
	# 确定父节点（分组）
	var parent = _get_scene_parent(scene_type, group_name)
	if not parent:
		push_error("Cannot find parent for scene: %s" % id)
		return null
	
	# 创建场景实例
	var scene = UIManager.resource_manager.get_scene_instance(
		scene_type.scene_path,
		scene_type.cache_mode == UIViewType.CACHE_MODE.CACHE_IN_MEMORY
	)
	
	if not scene:
		return null
	
	# 设置场景属性
	scene.layer = scene_type.layer
	
	# 添加到父节点
	parent.add_child(scene)
	
	# 处理分组堆栈
	var group_id = group_name if not group_name.is_empty() else scene_type.group_id
	if not group_id.is_empty():
		_push_to_group_stack(group_id, scene)
	
	# 初始化场景
	var component = UIManager.get_scene_component(scene)
	if component:
		component.initialize(data)
	elif scene.has_method("_setup"):
		scene._setup(data)
	
	# 处理过渡动画
	_handle_transition(scene, scene_type.transition)
	
	return scene

## 关闭场景
func close_scene(scene: Control) -> void:
	if not scene:
		return
	
	# 获取场景类型
	var scene_type = _get_scene_type_by_instance(scene)
	if not scene_type:
		scene.queue_free()
		return
	
	# 从分组堆栈中移除
	var group_id = scene_type.group_id
	if not group_id.is_empty():
		_pop_from_group_stack(group_id, scene)
	
	# 调用清理方法
	var component = UIManager.get_scene_component(scene)
	if component:
		component.dispose()
	elif scene.has_method("_cleanup"):
		scene._cleanup()
	
	# 处理缓存
	match scene_type.cache_mode:
		UIViewType.CACHE_MODE.CACHE_IN_MEMORY:
			UIManager.resource_manager.recycle_instance(scene_type.scene_path, scene)
		_:
			scene.queue_free()

## 获取场景父节点
func _get_scene_parent(scene_type: UISceneType, group_name: StringName) -> Node:
	# 优先使用传入的分组名
	var group_id = group_name if not group_name.is_empty() else scene_type.group_id
	
	if not group_id.is_empty():
		var group = UIManager.get_group(group_id)
		if group:
			return group.get_parent()
	
	# 如果没有指定分组，使用默认UI根节点
	return UIManager.get_ui_root()

## 将场景压入分组堆栈
func _push_to_group_stack(group_id: StringName, scene: Control) -> void:
	if not _group_stacks.has(group_id):
		_group_stacks[group_id] = Stack.new()
	
	var stack = _group_stacks[group_id]
	
	# 如果需要隐藏其他场景
	var scene_type = _get_scene_type_by_instance(scene)
	if scene_type and scene_type.hide_others:
		var current = stack.peek()
		if current:
			current.hide()
	
	stack.push(scene)

## 从分组堆栈移除场景
func _pop_from_group_stack(group_id: StringName, scene: Control) -> void:
	if not _group_stacks.has(group_id):
		return
		
	var stack = _group_stacks[group_id]
	if stack.peek() == scene:
		stack.pop()
		# 显示上一个场景
		var previous = stack.peek()
		if previous:
			previous.show()

## 处理过渡动画
func _handle_transition(scene: Control, p_transition: UITransition) -> void:
	var scene_type = _get_scene_type_by_instance(scene)
	var transition = p_transition
	if not transition and scene_type:
		transition = scene_type.transition
	if transition:
		transition.play(scene)

## 根据实例获取场景类型
func _get_scene_type_by_instance(scene: Control) -> UISceneType:
	for type in _scene_types.values():
		if type.scene_path == scene.scene_file_path:
			return type
	return null

## 获取分组当前场景
func get_group_current_scene(group_id: StringName) -> Control:
	if not _group_stacks.has(group_id):
		return null
	return _group_stacks[group_id].peek()

## 获取分组场景堆栈
func get_group_stack(group_id: StringName) -> Stack:
	if not _group_stacks.has(group_id):
		_group_stacks[group_id] = Stack.new()
	return _group_stacks[group_id]

## 关闭分组所有场景
func close_group_scenes(group_id: StringName) -> void:
	if not _group_stacks.has(group_id):
		return
		
	var stack = _group_stacks[group_id]
	while not stack.is_empty:
		var scene = stack.pop()
		if scene:
			close_scene(scene)
