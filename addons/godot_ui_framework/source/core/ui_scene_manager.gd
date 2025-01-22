extends UIViewManager
class_name UISceneManager

## 分组场景栈
var _group_stacks: Dictionary[StringName, Stack] = {}

## 创建场景
func create_scene(id: StringName, data: Dictionary = {}) -> Control:
	var scene_type = get_view_type(id) as UISceneType
	if not scene_type:
		push_error("Scene type not found: %s" % id)
		return null
	
	# 获取父节点（分组）
	var parent = _get_scene_parent(scene_type)
	if not parent:
		push_error("Cannot find parent for scene: %s" % id)
		return null
	
	var scene = super.create_view(id, parent, data) as Control
	if not scene:
		return null
	
	var component = UIManager.get_scene_component(scene)
	if not component:
		push_error("Scene component not found: %s" % id)
		scene.queue_free()
		return null
	
	# 处理分组堆栈
	if not scene_type.group_id.is_empty():
		_push_to_group_stack(scene_type.group_id, scene)
	
	return scene

## 关闭场景
func close_scene(scene: Control) -> void:
	if not scene:
		return
	
	var component = UIManager.get_scene_component(scene)
	if not component:
		scene.queue_free()
		return
	
	# 从分组堆栈中移除
	var group_id = component.group_id
	if not group_id.is_empty():
		_pop_from_group_stack(group_id, scene)
	
	destroy_view(scene)

## 获取场景父节点
func _get_scene_parent(scene_type: UISceneType) -> Node:
	if not scene_type.group_id.is_empty():
		var group : UIGroupComponent = UIManager.get_group(scene_type.group_id)
		if group:
			return group.ui_root
	return null

## 将场景压入分组堆栈
func _push_to_group_stack(group_id: StringName, scene: Control) -> void:
	if not _group_stacks.has(group_id):
		_group_stacks[group_id] = Stack.new()
	
	var stack = _group_stacks[group_id]
	var component = UIManager.get_scene_component(scene)
	
	# 如果需要隐藏其他场景
	if component and component.hide_others:
		if not stack.is_empty: 
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

## 注册场景类型
func register_scene_type(scene_type: UISceneType) -> void:
	super.register_view_type(scene_type)

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
