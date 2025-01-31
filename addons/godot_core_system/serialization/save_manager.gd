extends Node
class_name SaveManager

## 存档管理器

## 信号
signal save_created(save_id: String)
signal save_loaded(save_id: String)
signal save_deleted(save_id: String)
signal save_failed(save_id: String, error: String)
signal autosave_created(save_id: String)

## 存档相关常量
const SAVE_DIR = "user://saves"
const SAVE_EXT = ".save"
const SCREENSHOT_EXT = ".png"
const AUTOSAVE_PREFIX = "autosave_"
const MAX_AUTOSAVES = 3

## 配置
@export var enable_compression: bool = true
@export var enable_encryption: bool = false
@export var encryption_key: String = ""
@export var enable_autosave: bool = true
@export var autosave_interval: int = 300  # 5分钟
@export var max_saves: int = 100

## 私有变量
var _current_save: SaveData = null
var _autosave_timer: Timer = null
var _registered_types: Dictionary = {}
var _io_manager: AsyncIOManager = null

func _ready() -> void:
	# 确保存档目录存在
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	
	# 初始化IO管理器
	_io_manager = AsyncIOManager.new()
	add_child(_io_manager)
	_io_manager.io_completed.connect(_on_io_completed)
	_io_manager.io_error.connect(_on_io_error)
	
	# 设置自动保存定时器
	if enable_autosave:
		_autosave_timer = Timer.new()
		add_child(_autosave_timer)
		_autosave_timer.timeout.connect(_on_autosave_timer_timeout)
		_autosave_timer.start(autosave_interval)

## 异步创建存档
func create_save_async(save_name: String = "", take_screenshot: bool = true, callback: Callable = func(_success: bool, _save_id: String): pass) -> void:
	var save_data = SaveData.new()
	var save_id = _generate_save_id()
	var screenshot_path = ""
	
	if take_screenshot:
		screenshot_path = _take_screenshot(save_id)
	
	save_data.update_metadata(save_name, screenshot_path)
	
	# 收集所有注册类型的数据
	for type_name in _registered_types:
		var instance = _registered_types[type_name]
		if instance is Serializable:
			save_data.set_game_data(type_name, instance.serialize())
	
	_io_manager.write_async(
		_get_save_path(save_id),
		save_data.serialize(),
		enable_compression,
		enable_encryption,
		encryption_key,
		func(success: bool, _result: Variant):
			if success:
				save_created.emit(save_id)
				callback.call(true, save_id)
			else:
				callback.call(false, "")
	)

## 异步加载存档
func load_save_async(save_id: String, callback: Callable = func(_success: bool): pass) -> void:
	_io_manager.read_async(
		_get_save_path(save_id),
		enable_compression,
		enable_encryption,
		encryption_key,
		func(success: bool, result: Variant):
			if success and result:
				var save_data = SaveData.new()
				save_data.deserialize(result)
				
				# 恢复所有注册类型的数据
				for type_name in _registered_types:
					var instance = _registered_types[type_name]
					if instance is Serializable:
						var data = save_data.get_game_data(type_name)
						if data:
							instance.deserialize(data)
				
				_current_save = save_data
				save_loaded.emit(save_id)
			else:
				save_failed.emit(save_id, "Failed to load save file")
			
			callback.call(success)
	)

## 异步删除存档
func delete_save_async(save_id: String, callback: Callable = func(_success: bool): pass) -> void:
	var save_path = _get_save_path(save_id)
	var screenshot_path = _get_screenshot_path(save_id)
	
	var delete_count = 0
	var total_files = 2
	var success = true
	
	var check_complete = func():
		delete_count += 1
		if delete_count >= total_files:
			if success:
				save_deleted.emit(save_id)
			callback.call(success)
	
	_io_manager.delete_async(
		save_path,
		func(_success: bool, _result: Variant):
			success = success and _success
			check_complete.call()
	)
	
	_io_manager.delete_async(
		screenshot_path,
		func(_success: bool, _result: Variant):
			success = success and _success
			check_complete.call()
	)

## 异步获取所有存档
func get_all_saves_async(callback: Callable = func(_saves: Array[Dictionary]): pass) -> void:
	var saves: Array[Dictionary] = []
	var dir = DirAccess.open(SAVE_DIR)
	if not dir:
		callback.call(saves)
		return
	
	var save_files = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(SAVE_EXT):
			save_files.append(file_name.get_basename())
		file_name = dir.get_next()
	
	if save_files.is_empty():
		callback.call(saves)
		return
	
	var loaded_count = 0
	for save_id in save_files:
		_io_manager.read_async(
			_get_save_path(save_id),
			enable_compression,
			enable_encryption,
			encryption_key,
			func(success: bool, result: Variant):
				loaded_count += 1
				if success and result:
					var save_data = SaveData.new()
					save_data.deserialize(result)
					saves.append({
						"id": save_id,
						"metadata": save_data.metadata
					})
				
				if loaded_count >= save_files.size():
					# 按时间戳排序
					saves.sort_custom(func(a, b): return a.metadata.timestamp > b.metadata.timestamp)
					callback.call(saves)
		)

## 注册可序列化类型
func register_type(type_name: String, instance: Serializable) -> void:
	_registered_types[type_name] = instance

## 取消注册类型
func unregister_type(type_name: String) -> void:
	_registered_types.erase(type_name)

## 获取当前存档
func get_current_save() -> SaveData:
	return _current_save

## 创建自动存档
func create_autosave() -> void:
	var save_id = AUTOSAVE_PREFIX + str(Time.get_unix_time_from_system())
	if create_save_async("自动存档", true):
		autosave_created.emit(save_id)
		_cleanup_autosaves()

## 清理自动存档
func _cleanup_autosaves() -> void:
	var saves = get_all_saves_async(func(saves):
		var autosaves = saves.filter(func(save): return save.id.begins_with(AUTOSAVE_PREFIX))
		
		if autosaves.size() > MAX_AUTOSAVES:
			for i in range(MAX_AUTOSAVES, autosaves.size()):
				delete_save_async(autosaves[i].id)
	)

## 生成存档ID
func _generate_save_id() -> String:
	return str(Time.get_unix_time_from_system())

## 获取存档文件路径
func _get_save_path(save_id: String) -> String:
	return SAVE_DIR.path_join(save_id + SAVE_EXT)

## 获取截图文件路径
func _get_screenshot_path(save_id: String) -> String:
	return SAVE_DIR.path_join(save_id + SCREENSHOT_EXT)

## 截图
func _take_screenshot(save_id: String) -> String:
	var image = get_viewport().get_texture().get_image()
	var path = _get_screenshot_path(save_id)
	image.save_png(path)
	return path

## 自动保存定时器回调
func _on_autosave_timer_timeout() -> void:
	if enable_autosave:
		create_autosave()

## IO完成回调
func _on_io_completed(result: Variant) -> void:
	pass

## IO错误回调
func _on_io_error(error: String) -> void:
	pass
