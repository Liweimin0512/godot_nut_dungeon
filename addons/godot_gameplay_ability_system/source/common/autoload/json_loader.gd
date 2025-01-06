extends Node

## JSON资源加载器，负责加载和缓存JSON配置及其引用的资源

## 资源类型标记
const RESOURCE_TYPE_MARKERS = {
	"scene": "@scene://",           # 场景资源
	"texture": "@texture://",       # 贴图资源
	"audio": "@audio://",           # 音频资源
	"json": "@json://",             # 嵌套的JSON配置
	"resource": "@resource://",     # 资源
}

## 资源缓存
var _json_cache: Dictionary = {}      # JSON配置缓存
var _resource_cache: Dictionary = {}  # 资源缓存

## 加载线程
var _loading_thread: Thread
var _loading_mutex: Mutex
var _loading_semaphore: Semaphore
var _loading_queue: Array[Dictionary]
var _is_loading: bool = false

## 批量加载完成信号
signal batch_load_completed(results: Dictionary)
## 单个文件加载完成信号
signal json_loaded(path: String, data: Dictionary)

func _init() -> void:
	_loading_mutex = Mutex.new()
	_loading_semaphore = Semaphore.new()
	_loading_queue = []
	_start_loading_thread()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_stop_loading_thread()

## 启动加载线程
func _start_loading_thread() -> void:
	_loading_thread = Thread.new()
	_is_loading = true
	_loading_thread.start(_loading_thread_function)

## 停止加载线程
func _stop_loading_thread() -> void:
	_is_loading = false
	_loading_semaphore.post()  # 唤醒线程以便退出
	_loading_thread.wait_to_finish()

## 加载线程函数
func _loading_thread_function() -> void:
	while _is_loading:
		_loading_semaphore.wait()  # 等待加载请求
		if not _is_loading:
			break
			
		# 获取下一个加载任务
		_loading_mutex.lock()
		var task = _loading_queue.pop_front() if not _loading_queue.is_empty() else null
		_loading_mutex.unlock()
		
		if task:
			var result = _load_json_file(task.path)
			# 处理加载结果
			call_deferred("_on_json_loaded", task.path, result, task.callback)

## 异步加载JSON文件
func load_json_async(path: String, callback: Callable = Callable()) -> void:
	_loading_mutex.lock()
	_loading_queue.append({
		"path": path,
		"callback": callback
	})
	_loading_mutex.unlock()
	_loading_semaphore.post()

## 同步加载JSON文件
func load_json(path: String) -> Dictionary:
	if _json_cache.has(path):
		return _json_cache[path]
	return _load_json_file(path)

## 实际的JSON加载函数
func _load_json_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("JSON file not found: %s" % path)
		return {}
		
	var json_text = FileAccess.get_file_as_string(path)
	var json = JSON.parse_string(json_text)
	if not json is Dictionary:
		push_error("Invalid JSON format: %s" % path)
		return {}
		
	# 处理资源引用
	json = _process_resource_references(json)
	_json_cache[path] = json
	return json

## 处理JSON中的资源引用
func _process_resource_references(data: Variant) -> Variant:
	match typeof(data):
		TYPE_DICTIONARY:
			var result = {}
			for key in data:
				result[key] = _process_resource_references(data[key])
			return result
			
		TYPE_ARRAY:
			var result = []
			for item in data:
				result.append(_process_resource_references(item))
			return result
			
		TYPE_STRING:
			return _resolve_resource_path(data)
			
		_:
			return data

## 解析资源路径
func _resolve_resource_path(value: String) -> Variant:
	for marker in RESOURCE_TYPE_MARKERS:
		var prefix = RESOURCE_TYPE_MARKERS[marker]
		if value.begins_with(prefix):
			var path = value.substr(prefix.length())
			return _load_resource(path, marker)
	return value

## 加载资源
func _load_resource(path: String, type: String) -> Variant:
	if _resource_cache.has(path):
		return _resource_cache[path]
		
	var result: Variant
	if type == "json":
		result = load_json(path)  # 直接返回JSON数据作为字典
	elif ResourceLoader.exists(path):
		result = load(path)
	
	if result:
		_resource_cache[path] = result
		
	return result

## 加载完成回调
func _on_json_loaded(path: String, result: Dictionary, callback: Callable) -> void:
	_json_cache[path] = result
	if callback.is_valid():
		callback.call(result)

## 清除缓存
func clear_cache() -> void:
	_json_cache.clear()
	_resource_cache.clear()

## 预加载JSON文件
func preload_json(paths: Array[String]) -> void:
	for path in paths:
		load_json_async(path)

## 批量加载JSON文件
## paths: JSON文件路径数组
## callback: 全部加载完成后的回调
## progress_callback: 加载进度回调 (current, total)
func batch_load_json(paths: Array[String], 
		callback: Callable = Callable(),
		progress_callback: Callable = Callable()) -> void:
	var total = paths.size()
	var current = 0
	var results = {}
	
	# 如果没有文件需要加载
	if total == 0:
		if callback.is_valid():
			callback.call(results)
		batch_load_completed.emit(results)
		return
	
	# 处理每个文件加载完成的回调
	for path in paths:
		load_json_async(path, func(result: Dictionary) -> void:
			current += 1
			results[path] = result
			
			# 发送加载进度
			if progress_callback.is_valid():
				progress_callback.call(current, total)
			
			# 发送单个文件加载完成信号
			json_loaded.emit(path, result)
			
			# 检查是否全部加载完成
			if current == total:
				if callback.is_valid():
					callback.call(results)
				batch_load_completed.emit(results)
		)

## 同步批量加载JSON文件
## 注意：这会阻塞直到所有文件加载完成
func batch_load_json_sync(paths: Array[String]) -> Dictionary:
	var results = {}
	for path in paths:
		results[path] = load_json(path)
	return results

## 检查某个路径的JSON是否已缓存
func is_json_cached(path: String) -> bool:
	return _json_cache.has(path)

## 获取已缓存的JSON数据
func get_cached_json(path: String) -> Dictionary:
	return _json_cache.get(path, {})
