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
var _instance_cache: Dictionary = {}   # 实例缓存 <id, Array[Node]>
var _lazy_load_queue: Array = []       # 延迟加载队列 <{path:String, callback:Callable}>

## 初始化延迟加载定时器
func _init() -> void:
	_start_lazy_load_timer()

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

## 获取场景实例
## 如果启用了对象池，会从池中获取实例
func get_scene_instance(path: String, use_pool: bool = false) -> Node:
	# 1. 尝试从对象池获取
	if use_pool and _instance_cache.has(path) and not _instance_cache[path].is_empty():
		return _instance_cache[path].pop_back()
	
	# 2. 加载场景并实例化
	var scene = load_scene(path)
	if not scene:
		return null
	
	return scene.instantiate()

## 回收实例到对象池
func recycle_instance(path: String, instance: Node) -> void:
	if not _instance_cache.has(path):
		_instance_cache[path] = []
	
	# 检查缓存大小
	if _instance_cache[path].size() >= max_cache_size:
		instance.queue_free()
		return
	
	# 从父节点移除并加入缓存
	if instance.get_parent():
		instance.get_parent().remove_child(instance)
	_instance_cache[path].append(instance)

## 清理资源
func clear_cache(path: String = "") -> void:
	if path.is_empty():
		# 清理所有缓存
		_scene_cache.clear()
		_clear_instance_cache()
	else:
		# 清理指定路径的缓存
		_scene_cache.erase(path)
		_clear_instance_cache(path)

## 缓存场景资源
func _cache_scene(path: String, scene: PackedScene) -> void:
	_scene_cache[path] = scene
	
	# 如果缓存超出限制，移除最早的缓存
	if _scene_cache.size() > max_cache_size:
		var oldest_path = _scene_cache.keys()[0]
		_scene_cache.erase(oldest_path)

## 清理实例缓存
func _clear_instance_cache(path: String = "") -> void:
	if path.is_empty():
		# 清理所有实例缓存
		for instances in _instance_cache.values():
			for instance in instances:
				instance.queue_free()
		_instance_cache.clear()
	else:
		# 清理指定路径的实例缓存
		if _instance_cache.has(path):
			for instance in _instance_cache[path]:
				instance.queue_free()
			_instance_cache.erase(path)

## 添加到延迟加载队列
func _queue_lazy_load(path: String, callback: Callable = Callable()) -> void:
	_lazy_load_queue.append({
		"path": path,
		"callback": callback
	})

## 处理延迟加载队列
func _process_lazy_load_queue() -> void:
	if _lazy_load_queue.is_empty():
		_start_lazy_load_timer()
		return
	
	var item = _lazy_load_queue.pop_front()
	var scene = _load_scene_immediate(item.path)
	
	if item.callback.is_valid():
		item.callback.call(scene)
	
	_start_lazy_load_timer()

## 开始延迟加载定时器
func _start_lazy_load_timer() -> void:
	var timer = UIManager.create_timer(lazy_load_interval)
	timer.timeout.connect(_process_lazy_load_queue)
