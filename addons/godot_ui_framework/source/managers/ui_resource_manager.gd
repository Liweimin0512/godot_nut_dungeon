extends RefCounted
class_name UIResourceManager

## 最大缓存数量
@export var max_instance_cache_size : int = 10
## 懒加载时间间隔
@export var lazy_load_interval : float = 1.0
## 资源缓存
var _resource_cache: Dictionary[StringName, UIWidgetType] = {}
## 预加载的场景
var _preloaded_scenes: Dictionary = {}
## 实例缓存
var _instance_cache: Dictionary = {}
## 正在加载的资源
var _loading_resources: Array[UIWidgetType] = []

func _ready() -> void:
	UIManager.create_timer(lazy_load_interval).timeout.connect(_on_idle_timer_timeout)

## 预加载UI
func preload_ui(ui_type: UIWidgetType) -> void:
	if _resource_cache.has(ui_type.ID):
		push_warning("UI already cached: %s" % ui_type.ID)
		return
		
	if _loading_resources.has(ui_type.ID):
		push_warning("UI already loading: %s" % ui_type.ID)
		return
	_resource_cache[ui_type.ID] = ui_type
	match ui_type.preload_mode:
		UIWidgetType.PRELOAD_MODE.PRELOAD:
			_load_ui_resource(ui_type)
		UIWidgetType.PRELOAD_MODE.LAZY_LOAD:
			_loading_resources.append(ui_type)
		UIWidgetType.PRELOAD_MODE.ON_DEMAND:
			pass # 按需加载不需要预加载

## 卸载UI
func unload_ui(ui_type: UIWidgetType) -> void:
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
func get_ui_instance(ui_type: UIWidgetType) -> Control:
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
		UIWidgetType.CACHE_MODE.CACHE_IN_MEMORY:
			_instance_cache[ui_id] = instance
		UIWidgetType.CACHE_MODE.SMART_CACHE:
			if _should_cache_instance():
				_instance_cache[ui_id] = instance
	
	return instance

## 获取UI资源
func _get_ui_resource(ui_type: UIWidgetType) -> PackedScene:
	var ui_id = ui_type.ID
	
	# 检查资源缓存
	if _resource_cache.has(ui_id):
		return _resource_cache[ui_id]
	
	# 加载资源
	return _load_ui_resource(ui_type)

## 加载UI资源
func _load_ui_resource(ui_type: UIWidgetType) -> PackedScene:
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
	var ui_type = _loading_resources[0]
	_loading_resources.remove_at(0)
	_load_ui_resource(ui_type)
	UIManager.create_timer(lazy_load_interval).timeout.connect(_on_idle_timer_timeout)

## 判断是否应该缓存实例
## 这里可以根据实际需求实现更复杂的判断逻辑
func _should_cache_instance() -> bool:
	# 示例：检查当前缓存的实例数量
	return _instance_cache.size() < max_instance_cache_size  # 最多缓存10个实例
