extends Node
class_name UIResourceManager

## 资源缓存
var _resource_cache: Dictionary = {}
## 预加载的场景
var _preloaded_scenes: Dictionary = {}
## 实例缓存
var _instance_cache: Dictionary = {}
## 正在加载的资源
var _loading_resources: Array[StringName] = []
## 空闲时间计时器
var _idle_timer: Timer

## 初始化# 在UIManager中
var _resource_manager: UIResourceManager

func _ready() -> void:
	_idle_timer = Timer.new()
	_idle_timer.wait_time = 1.0  # 每秒检查一次
	_idle_timer.timeout.connect(_on_idle_timer_timeout)
	add_child(_idle_timer)
	_idle_timer.start()
    _resource_manager = UIResourceManager.new()
    add_child(_resource_manager)

func create_interface(ID: StringName, data: Dictionary = {}) -> Control:
    var ui_type = _get_type(ID)
    if not ui_type:
        return null
    
    var interface = _resource_manager.get_ui_instance(ui_type)
    # ... 其他初始化代码 ...
    return interface

## 预加载UI
func preload_ui(ui_type: UIType) -> void:
	if _resource_cache.has(ui_type.ID) or _loading_resources.has(ui_type.ID):
		return
		
	match ui_type.preload_mode:
		UIType.PRELOAD_MODE.PRELOAD:
			_load_ui_resource(ui_type)
		UIType.PRELOAD_MODE.LAZY_LOAD:
			_loading_resources.append(ui_type.ID)
		UIType.PRELOAD_MODE.ON_DEMAND:
			pass # 按需加载不需要预加载

## 卸载UI
func unload_ui(ui_type: UIType) -> void:
	var ui_id = ui_type.ID
	
	# 从加载队列中移除
	_loading_resources.erase(ui_id)
	
	# 处理实例缓存
	if _instance_cache.has(ui_id):
		var instance = _instance_cache[ui_id]
		if is_instance_valid(instance):
			instance.queue_free()
		_instance_cache.erase(ui_id)
	
	# 处理资源缓存
	if _resource_cache.has(ui_id):
		# 注意：资源的释放由Godot的引用计数系统处理
		_resource_cache.erase(ui_id)

## 获取UI实例
func get_ui_instance(ui_type: UIType) -> Control:
	var ui_id = ui_type.ID
	
	# 检查实例缓存
	if _instance_cache.has(ui_id) and is_instance_valid(_instance_cache[ui_id]):
		return _instance_cache[ui_id]
	
	# 加载资源
	var scene = _get_ui_resource(ui_type)
	if not scene:
		return null
	
	# 实例化
	var instance = scene.instantiate()
	
	# 根据缓存策略处理
	match ui_type.cache_mode:
		UIType.CACHE_MODE.CACHE_IN_MEMORY:
			_instance_cache[ui_id] = instance
		UIType.CACHE_MODE.SMART_CACHE:
			if _should_cache_instance():
				_instance_cache[ui_id] = instance
	
	return instance

## 获取UI资源
func _get_ui_resource(ui_type: UIType) -> PackedScene:
	var ui_id = ui_type.ID
	
	# 检查资源缓存
	if _resource_cache.has(ui_id):
		return _resource_cache[ui_id]
	
	# 加载资源
	return _load_ui_resource(ui_type)

## 加载UI资源
func _load_ui_resource(ui_type: UIType) -> PackedScene:
	var ui_id = ui_type.ID
	
	if not ui_type.scene:
		push_error("UI scene is null for %s" % ui_id)
		return null
	
	var scene = ui_type.scene
	_resource_cache[ui_id] = scene
	return scene

## 空闲时间处理
func _on_idle_timer_timeout() -> void:
	if _loading_resources.is_empty():
		return
	
	# 每次处理一个待加载的资源
	var ui_id = _loading_resources[0]
	_loading_resources.remove_at(0)
	
	# 查找对应的UIType并加载
	# 注意：这里需要一个方法来获取UIType，可能需要UIManager的支持
	# var ui_type = UIManager.get_ui_type(ui_id)
	# if ui_type:
	#     _load_ui_resource(ui_type)

## 判断是否应该缓存实例
## 这里可以根据实际需求实现更复杂的判断逻辑
func _should_cache_instance() -> bool:
	# 示例：检查当前缓存的实例数量
	return _instance_cache.size() < 10  # 最多缓存10个实例