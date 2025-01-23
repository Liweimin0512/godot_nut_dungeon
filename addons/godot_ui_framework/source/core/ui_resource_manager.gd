extends RefCounted
class_name UIResourceManager

## UI资源管理器，负责管理UI场景的加载、缓存和实例化
##
## 提供了同步和异步的资源加载方式，以及对象池功能来优化性能
## 支持场景资源的缓存管理和自动清理

## 资源加载模式
enum LoadMode {
	IMMEDIATE,  ## 立即加载 - 同步加载资源
	LAZY,       ## 延迟加载 - 异步加载，在下一帧处理
	ON_DEMAND   ## 按需加载 - 仅在实际需要时加载
}

## 信号
signal scene_loaded(path: String, scene: PackedScene)  ## 场景加载完成时发出
signal instance_recycled(cache_key: StringName, instance: Node)  ## 实例被回收时发出

## 配置参数
@export var max_cache_size: int = 10:  ## 最大缓存数量
	set(value):
		max_cache_size = max(1, value)  # 确保至少为1
		
@export var lazy_load_interval: float = 1.0:  ## 延迟加载间隔（秒）
	set(value):
		lazy_load_interval = max(0.1, value)  # 确保至少为0.1秒

## 内部变量
var _scene_cache: Dictionary = {}      ## 场景缓存 <path: String, scene: PackedScene>
var _instance_cache: Dictionary = {}   ## 实例缓存 <cache_key: StringName, instances: Array[Node]>
var _lazy_load_queue: Array[Dictionary] = []  ## 延迟加载队列
var _lazy_load_timer: SceneTreeTimer   ## 延迟加载定时器

## 加载场景资源
## [param path] 场景路径
## [param mode] 加载模式
## [param callback] 加载完成后的回调函数（仅用于LAZY模式）
## [return] 加载的场景资源，如果是延迟加载则返回null
func load_scene(path: String, mode: LoadMode = LoadMode.IMMEDIATE, callback: Callable = Callable()) -> PackedScene:
	# 检查路径有效性
	if path.is_empty():
		push_error("[UIResourceManager] Invalid scene path: empty path")
		return null
		
	# 检查缓存
	if _scene_cache.has(path):
		var cached_scene = _scene_cache[path]
		if callback.is_valid():
			callback.call(cached_scene)
		return cached_scene
		
	# 根据加载模式处理
	match mode:
		LoadMode.IMMEDIATE:
			return _load_scene_immediate(path)
		LoadMode.LAZY:
			_queue_lazy_load(path, callback)
			return null
		LoadMode.ON_DEMAND:
			return null
		_:
			push_error("[UIResourceManager] Invalid load mode: %d" % mode)
			return null

## 获取或创建实例
## [param cache_key] 缓存键，可以是场景路径或自定义ID
## [param scene_path] 场景路径（仅在需要创建新实例时使用）
## [param use_pool] 是否使用对象池
## [return] 返回场景实例，失败时返回null
func get_instance(cache_key: StringName, scene_path: String = "", use_pool: bool = false) -> Node:
	if cache_key.is_empty():
		push_error("[UIResourceManager] Invalid cache key: empty key")
		return null
	
	# 尝试从对象池获取
	if use_pool and _has_pooled_instance(cache_key):
		return _get_pooled_instance(cache_key)
	
	# 如果没有提供场景路径，无法创建新实例
	if scene_path.is_empty():
		return null
	
	# 加载场景并实例化
	var scene := load_scene(scene_path)
	if not scene:
		push_error("[UIResourceManager] Failed to load scene: %s" % scene_path)
		return null
	
	var instance := scene.instantiate()
	if not instance:
		push_error("[UIResourceManager] Failed to instantiate scene: %s" % scene_path)
		return null
		
	return instance

## 回收实例到对象池
## [param cache_key] 缓存键
## [param instance] 要回收的实例
func recycle_instance(cache_key: StringName, instance: Node) -> void:
	if not instance:
		push_error("[UIResourceManager] Cannot recycle null instance")
		return
		
	if cache_key.is_empty():
		push_error("[UIResourceManager] Invalid cache key for recycling")
		return
	
	# 初始化缓存数组（如果不存在）
	if not _instance_cache.has(cache_key):
		_instance_cache[cache_key] = []
	
	# 检查缓存大小限制
	if _instance_cache[cache_key].size() >= max_cache_size:
		instance.queue_free()
		return
	
	# 从父节点移除并加入缓存
	if instance.get_parent():
		instance.get_parent().remove_child(instance)
	_instance_cache[cache_key].append(instance)
	
	# 发出信号
	instance_recycled.emit(cache_key, instance)

## 清理资源缓存
## [param cache_key] 要清理的缓存键，为空时清理所有缓存
func clear_cache(cache_key: StringName = "") -> void:
	if cache_key.is_empty():
		_clear_all_cache()
	else:
		_clear_specific_cache(cache_key)

## 立即加载场景
func _load_scene_immediate(path: String) -> PackedScene:
	if not ResourceLoader.exists(path):
		push_error("[UIResourceManager] Scene not found: %s" % path)
		return null
		
	var scene := load(path) as PackedScene
	if scene:
		_cache_scene(path, scene)
		scene_loaded.emit(path, scene)
	return scene

## 检查是否有可用的池化实例
func _has_pooled_instance(cache_key: StringName) -> bool:
	return _instance_cache.has(cache_key) and not _instance_cache[cache_key].is_empty()

## 从对象池获取实例
func _get_pooled_instance(cache_key: StringName) -> Node:
	return _instance_cache[cache_key].pop_back()

## 缓存场景资源
func _cache_scene(path: String, scene: PackedScene) -> void:
	_scene_cache[path] = scene
	
	# 如果缓存超出限制，移除最早的缓存
	while _scene_cache.size() > max_cache_size:
		var oldest_path = _scene_cache.keys()[0]
		_scene_cache.erase(oldest_path)

## 清理所有缓存
func _clear_all_cache() -> void:
	# 清理场景缓存
	_scene_cache.clear()
	
	# 清理实例缓存
	for instances in _instance_cache.values():
		for instance in instances:
			if is_instance_valid(instance):
				instance.queue_free()
	_instance_cache.clear()
	
	# 清理加载队列
	_lazy_load_queue.clear()

## 清理指定缓存
func _clear_specific_cache(cache_key: StringName) -> void:
	# 如果是场景路径，清理场景缓存
	if ResourceLoader.exists(cache_key):
		_scene_cache.erase(cache_key)
	
	# 清理实例缓存
	if _instance_cache.has(cache_key):
		for instance in _instance_cache[cache_key]:
			if is_instance_valid(instance):
				instance.queue_free()
		_instance_cache.erase(cache_key)

## 添加到延迟加载队列
func _queue_lazy_load(path: String, callback: Callable = Callable()) -> void:
	_lazy_load_queue.append({
		"path": path,
		"callback": callback
	})
	
	_ensure_lazy_load_timer()

## 确保延迟加载定时器在运行
func _ensure_lazy_load_timer() -> void:
	if not _lazy_load_timer or not _lazy_load_timer.time_left > 0:
		_lazy_load_timer = UIManager.get_tree().create_timer(lazy_load_interval)
		_lazy_load_timer.timeout.connect(_process_lazy_load_queue)

## 处理延迟加载队列
func _process_lazy_load_queue() -> void:
	if _lazy_load_queue.is_empty():
		return
	
	var item := _lazy_load_queue.pop_front()
	var scene := _load_scene_immediate(item.path)
	
	if item.callback.is_valid():
		item.callback.call(scene)
	
	# 如果队列不为空，继续处理
	if not _lazy_load_queue.is_empty():
		_ensure_lazy_load_timer()
