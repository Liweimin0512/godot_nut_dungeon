extends RefCounted
class_name UIResourceManager

## 资源加载模式
enum LoadMode {
	IMMEDIATE,  # 立即加载
	LAZY,       # 延迟加载
	ON_DEMAND   # 按需加载
}

## 配置参数
var max_cache_size: int = 10           # 最大缓存数量
var lazy_load_interval: float = 1.0    # 延迟加载间隔

## 资源缓存
var _scene_cache: Dictionary = {}      # 场景缓存 <path, PackedScene>
var _instance_cache: Dictionary = {}   # 实例缓存 <cache_key, Array[Node]>
var _lazy_load_queue: Array = []       # 延迟加载队列 <{path:String, callback:Callable}>
var _lazy_load_timer: SceneTreeTimer   # 延迟加载定时器

## 加载场景资源
## 支持同步和异步加载
func load_scene(path: String, mode: LoadMode = LoadMode.IMMEDIATE) -> PackedScene:
	# 1. 检查缓存
	if _scene_cache.has(path):
		return _scene_cache[path]
		
	# 2. 根据加载模式处理
	match mode:
		LoadMode.IMMEDIATE:
			return _load_scene_immediate(path)
		LoadMode.LAZY:
			_queue_lazy_load(path)
			return null
		LoadMode.ON_DEMAND:
			return null
	
	return null

## 立即加载场景
func _load_scene_immediate(path: String) -> PackedScene:
	if not ResourceLoader.exists(path):
		push_error("Scene not found: %s" % path)
		return null
		
	var scene = load(path) as PackedScene
	if scene:
		_cache_scene(path, scene)
	return scene

## 获取实例
## 如果启用了对象池，会从池中获取实例
## cache_key: 缓存键，可以是场景路径或widget ID
## use_pool: 是否使用对象池
func get_instance(cache_key: StringName, scene_path: String = "", use_pool: bool = false) -> Node:
	# 1. 尝试从对象池获取
	if use_pool and _instance_cache.has(cache_key) and not _instance_cache[cache_key].is_empty():
		return _instance_cache[cache_key].pop_back()
	
	# 2. 如果是widget，scene_path为空，直接返回null
	if scene_path.is_empty():
		return null
	
	# 3. 加载场景并实例化
	var scene = load_scene(scene_path)
	if not scene:
		return null
	
	return scene.instantiate()

## 回收实例到对象池
func recycle_instance(cache_key: StringName, instance: Node) -> void:
	if not _instance_cache.has(cache_key):
		_instance_cache[cache_key] = []
	
	# 检查缓存大小
	if _instance_cache[cache_key].size() >= max_cache_size:
		instance.queue_free()
		return
	
	# 从父节点移除并加入缓存
	if instance.get_parent():
		instance.get_parent().remove_child(instance)
	_instance_cache[cache_key].append(instance)

## 清理资源
func clear_cache(cache_key: StringName = "") -> void:
	if cache_key.is_empty():
		# 清理所有缓存
		_scene_cache.clear()
		_clear_instance_cache()
	else:
		# 清理指定缓存
		if ResourceLoader.exists(cache_key):
			_scene_cache.erase(cache_key)
		_clear_instance_cache(cache_key)

## 缓存场景资源
func _cache_scene(path: String, scene: PackedScene) -> void:
	_scene_cache[path] = scene
	
	# 如果缓存超出限制，移除最早的缓存
	if _scene_cache.size() > max_cache_size:
		var oldest_path = _scene_cache.keys()[0]
		_scene_cache.erase(oldest_path)

## 清理实例缓存
func _clear_instance_cache(cache_key: StringName = "") -> void:
	if cache_key.is_empty():
		# 清理所有实例缓存
		for instances in _instance_cache.values():
			for instance in instances:
				instance.queue_free()
		_instance_cache.clear()
	else:
		# 清理指定key的实例缓存
		if _instance_cache.has(cache_key):
			for instance in _instance_cache[cache_key]:
				instance.queue_free()
			_instance_cache.erase(cache_key)

## 添加到延迟加载队列
func _queue_lazy_load(path: String, callback: Callable = Callable()) -> void:
	_lazy_load_queue.append({
		"path": path,
		"callback": callback
	})
	
	# 确保定时器在运行
	_ensure_lazy_load_timer()

## 确保延迟加载定时器在运行
func _ensure_lazy_load_timer() -> void:
	if not _lazy_load_timer or not _lazy_load_timer.time_left:
		_lazy_load_timer = UIManager.get_tree().create_timer(lazy_load_interval)
		_lazy_load_timer.timeout.connect(_process_lazy_load_queue)

## 处理延迟加载队列
func _process_lazy_load_queue() -> void:
	if _lazy_load_queue.is_empty():
		return
	
	var item = _lazy_load_queue.pop_front()
	var instance = _load_instance_immediate(item.path)
	if item.has("callback"):
		item.callback.call(instance)
	
	# 如果队列不为空，继续处理
	if not _lazy_load_queue.is_empty():
		_ensure_lazy_load_timer()
