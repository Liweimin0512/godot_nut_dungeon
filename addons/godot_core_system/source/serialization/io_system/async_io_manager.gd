extends "res://addons/godot_core_system/source/manager_base.gd"

## 异步IO管理器

# 信号
## IO完成
signal io_completed(task_id: String, success: bool, result: Variant)
## IO进度
signal io_progress(task_id: String, progress: float)
## IO错误
signal io_error(task_id: String, error: String)

## IO任务类型
enum TaskType {
	READ,			# 读取
	WRITE,			# 写入
	DELETE,			# 删除
}

## IO任务状态
enum TaskStatus {
	PENDING,		# 未开始
	RUNNING,		# 运行中
	COMPLETED,		# 完成
	ERROR,			# 错误
}

## 任务队列
var _tasks: Array[IOTask] = []
## 工作线程
var _thread: Thread
## 线程同步信号量
var _semaphore: Semaphore
## 线程运行标志
var _running: bool = true
## 互斥锁
var _mutex: Mutex

func _init():
	_semaphore = Semaphore.new()
	_mutex = Mutex.new()
	_thread = Thread.new()
	_thread.start(_thread_function)

func _exit() -> void:
	# 停止工作线程
	_running = false
	_semaphore.post()
	_thread.wait_to_finish()

## 异步读取文件
## [param path] 文件路径
## [param compression] 是否压缩
## [param encryption] 是否加密
## [param encryption_key] 加密密钥
## [param callback] 回调函数
## [return] 任务ID
func read_file_async(
	path: String, 
	compression: bool = false,
	encryption: bool = false,
	encryption_key: String = "",
	callback: Callable = func(_success: bool, _result: Variant): pass
) -> String:
	var task_id = str(Time.get_unix_time_from_system())
	var task = IOTask.new(
		task_id,
		TaskType.READ,
		path,
		null,
		compression,
		encryption,
		encryption_key,
		callback
	)
	
	_mutex.lock()
	_tasks.append(task)
	_mutex.unlock()
	
	_semaphore.post()
	return task_id

## 异步写入文件
## [param path] 文件路径
## [param data] 数据
## [param compression] 是否压缩
## [param encryption] 是否加密
## [param encryption_key] 加密密钥
## [param callback] 回调函数
## [return] 任务ID
func write_file_async(
	path: String, 
	data: Variant,
	compression: bool = false,
	encryption: bool = false,
	encryption_key: String = "",
	callback: Callable = func(_success: bool, _result: Variant): pass
) -> String:
	var task_id = str(Time.get_unix_time_from_system())
	var task = IOTask.new(
		task_id,
		TaskType.WRITE,
		path,
		data,
		compression,
		encryption,
		encryption_key,
		callback
	)
	
	_mutex.lock()
	_tasks.append(task)
	_mutex.unlock()
	
	_semaphore.post()
	return task_id

## 异步删除文件
## [param path] 文件路径
## [param callback] 回调函数
## [return] 任务ID
func delete_file_async(
	path: String, 
	callback: Callable = func(_success: bool, _result: Variant): pass
) -> String:
	var task_id = str(Time.get_unix_time_from_system())
	var task = IOTask.new(
		task_id,
		TaskType.DELETE,
		path,
		null,
		false,
		false,
		"",
		callback
	)
	
	_mutex.lock()
	_tasks.append(task)
	_mutex.unlock()
	
	_semaphore.post()
	return task_id

## 工作线程函数
func _thread_function() -> void:
	while _running:
		_semaphore.wait()
		
		if not _running:
			break
		
		_mutex.lock()
		var task = _tasks.pop_front() if not _tasks.is_empty() else null
		_mutex.unlock()
		
		if task:
			task.status = TaskStatus.RUNNING
			
			match task.type:
				TaskType.READ:
					_handle_read_task(task)
				TaskType.WRITE:
					_handle_write_task(task)
				TaskType.DELETE:
					_handle_delete_task(task)

## 处理读取任务
## [param task] 任务
func _handle_read_task(task: IOTask) -> void:
	if not FileAccess.file_exists(task.path):
		call_deferred("_complete_task", task, false, null, "File not found")
		return
	
	var file = FileAccess.open(task.path, FileAccess.READ)
	if not file:
		call_deferred("_complete_task", task, false, null, "Failed to open file")
		return
	
	var content = file.get_as_text()
	file.close()
	
	# 解密
	if task.encryption and task.encryption_key != "":
		content = content.decrypt(task.encryption_key)
	
	# 解压
	if task.compression:
		content = content.decompress()
	
	# 解析JSON
	var parse_result = JSON.parse_string(content)
	if parse_result == null:
		call_deferred("_complete_task", task, false, null, "Failed to parse JSON")
		return
	
	call_deferred("_complete_task", task, true, parse_result)

## 处理写入任务
## [param task] 任务
func _handle_write_task(task: IOTask) -> void:
	# 确保目录存在
	DirAccess.make_dir_recursive_absolute(task.path.get_base_dir())
	
	var file = FileAccess.open(task.path, FileAccess.WRITE)
	if not file:
		call_deferred("_complete_task", task, false, null, "Failed to open file")
		return
	
	var content = JSON.stringify(task.data)
	
	# 压缩
	if task.compression:
		content = content.compress()
	
	# 加密
	if task.encryption and task.encryption_key != "":
		content = content.encrypt(task.encryption_key)
	
	file.store_string(content)
	file.close()
	
	call_deferred("_complete_task", task, true, null)

## 处理删除任务
## [param task] 任务
func _handle_delete_task(task: IOTask) -> void:
	if not FileAccess.file_exists(task.path):
		call_deferred("_complete_task", task, false, null, "File not found")
		return
	
	var error = DirAccess.remove_absolute(task.path)
	if error != OK:
		call_deferred("_complete_task", task, false, null, "Failed to delete file")
		return
	
	call_deferred("_complete_task", task, true, null)

## 完成任务
## [param task] 任务
## [param success] 成功
## [param result] 结果
## [param error] 错误
func _complete_task(task: IOTask, success: bool, result: Variant = null, error: String = "") -> void:
	task.status = TaskStatus.COMPLETED if success else TaskStatus.ERROR
	task.error = error
	
	if success:
		io_completed.emit(task.id, true, result)
	else:
		io_error.emit(task.id, error)
		io_completed.emit(task.id, false, null)
	
	task.callback.call(success, result)

## IO任务
class IOTask:
	## 任务ID
	var id: String
	## 任务类型
	var type: TaskType
	## 路径
	var path: String
	## 数据
	var data: Variant
	## 状态
	var status: TaskStatus
	## 错误
	var error: String
	## 回调
	var callback: Callable
	## 压缩
	var compression: bool
	## 加密
	var encryption: bool
	## 加密密钥
	var encryption_key: String
	
	func _init(
		_id: String, 
		_type: TaskType, 
		_path: String, 
		_data: Variant = null,
		_compression: bool = false,
		_encryption: bool = false,
		_encryption_key: String = "",
		_callback: Callable = func(_success: bool, _result: Variant): pass
	) -> void:
		id = _id
		type = _type
		path = _path
		data = _data
		status = TaskStatus.PENDING
		compression = _compression
		encryption = _encryption
		encryption_key = _encryption_key
		callback = _callback
