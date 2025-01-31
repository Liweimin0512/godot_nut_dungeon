extends Node
class_name AsyncIOManager

## 异步IO管理器

## 信号
signal io_completed(task_id: String, success: bool, result: Variant)
signal io_progress(task_id: String, progress: float)
signal io_error(task_id: String, error: String)

## IO任务类型
enum TaskType {
	READ,
	WRITE,
	DELETE,
}

## IO任务状态
enum TaskStatus {
	PENDING,
	RUNNING,
	COMPLETED,
	ERROR,
}

## IO任务
class IOTask:
	var id: String
	var type: TaskType
	var path: String
	var data: Variant
	var status: TaskStatus
	var error: String
	var callback: Callable
	var compression: bool
	var encryption: bool
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

## 任务队列
var _tasks: Array[IOTask] = []
## 工作线程
var _thread: Thread = null
## 互斥锁
var _mutex: Mutex = Mutex.new()
## 信号量
var _semaphore: Semaphore = Semaphore.new()
## 是否正在运行
var _running: bool = false

func _ready() -> void:
	# 启动工作线程
	_running = true
	_thread = Thread.new()
	_thread.start(_thread_function)

func _exit_tree() -> void:
	# 停止工作线程
	_running = false
	_semaphore.post()
	_thread.wait_to_finish()

## 添加读取任务
func read_async(
	path: String, 
	compression: bool = false,
	encryption: bool = false,
	encryption_key: String = "",
	callback: Callable = func(_success: bool, _result: Variant): pass
) -> String:
	var task = IOTask.new(
		str(Time.get_unix_time_from_system()),
		TaskType.READ,
		path,
		null,
		compression,
		encryption,
		encryption_key,
		callback
	)
	_add_task(task)
	return task.id

## 添加写入任务
func write_async(
	path: String, 
	data: Variant,
	compression: bool = false,
	encryption: bool = false,
	encryption_key: String = "",
	callback: Callable = func(_success: bool, _result: Variant): pass
) -> String:
	var task = IOTask.new(
		str(Time.get_unix_time_from_system()),
		TaskType.WRITE,
		path,
		data,
		compression,
		encryption,
		encryption_key,
		callback
	)
	_add_task(task)
	return task.id

## 添加删除任务
func delete_async(
	path: String,
	callback: Callable = func(_success: bool, _result: Variant): pass
) -> String:
	var task = IOTask.new(
		str(Time.get_unix_time_from_system()),
		TaskType.DELETE,
		path,
		null,
		false,
		false,
		"",
		callback
	)
	_add_task(task)
	return task.id

## 添加任务到队列
func _add_task(task: IOTask) -> void:
	_mutex.lock()
	_tasks.append(task)
	_mutex.unlock()
	_semaphore.post()

## 获取下一个任务
func _get_next_task() -> IOTask:
	_mutex.lock()
	var task = _tasks.pop_front() if _tasks.size() > 0 else null
	_mutex.unlock()
	return task

## 工作线程函数
func _thread_function() -> void:
	while _running:
		_semaphore.wait()
		
		if not _running:
			break
		
		var task = _get_next_task()
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
func _handle_read_task(task: IOTask) -> void:
	if not FileAccess.file_exists(task.path):
		call_deferred("_complete_task", task, false, null, "File not found")
		return
	
	var file = FileAccess.open(task.path, FileAccess.READ)
	if not file:
		call_deferred("_complete_task", task, false, null, "Failed to open file")
		return
	
	var content = file.get_as_text()
	
	if task.encryption and task.encryption_key:
		content = content.decrypt(task.encryption_key)
	
	if task.compression:
		content = content.decompress()
	
	var parse_result = JSON.parse_string(content)
	if parse_result == null:
		call_deferred("_complete_task", task, false, null, "Failed to parse file content")
		return
	
	call_deferred("_complete_task", task, true, parse_result)

## 处理写入任务
func _handle_write_task(task: IOTask) -> void:
	# 确保目录存在
	DirAccess.make_dir_recursive_absolute(task.path.get_base_dir())
	
	var file = FileAccess.open(task.path, FileAccess.WRITE)
	if not file:
		call_deferred("_complete_task", task, false, null, "Failed to open file for writing")
		return
	
	var content = JSON.stringify(task.data)
	
	if task.compression:
		content = content.compress()
	
	if task.encryption and task.encryption_key:
		content = content.encrypt(task.encryption_key)
	
	file.store_string(content)
	call_deferred("_complete_task", task, true, null)

## 处理删除任务
func _handle_delete_task(task: IOTask) -> void:
	if not FileAccess.file_exists(task.path):
		call_deferred("_complete_task", task, false, null, "File not found")
		return
	
	var err = DirAccess.remove_absolute(task.path)
	if err != OK:
		call_deferred("_complete_task", task, false, null, "Failed to delete file")
		return
	
	call_deferred("_complete_task", task, true, null)

## 完成任务
func _complete_task(task: IOTask, success: bool, result: Variant = null, error: String = "") -> void:
	task.status = TaskStatus.COMPLETED if success else TaskStatus.ERROR
	task.error = error
	
	if success:
		io_completed.emit(task.id, true, result)
	else:
		io_error.emit(task.id, error)
		io_completed.emit(task.id, false, null)
	
	task.callback.call(success, result)
