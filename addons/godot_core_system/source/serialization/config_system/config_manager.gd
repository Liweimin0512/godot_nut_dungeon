extends "res://addons/godot_core_system/source/manager_base.gd"

## 配置管理器

# 信号
## 配置加载
signal config_loaded
## 配置保存
signal config_saved
## 配置重置
signal config_reset

## 配置文件路径
@export var config_path: String = "user://config.cfg"
## 默认配置
@export var default_config: Dictionary = {}
## 是否自动保存
@export var auto_save: bool = true

## 当前配置
var _config: Dictionary = {}
## 异步IO管理器
var _io_manager: AsyncIOManager
## 是否已修改
var _modified: bool = false

func _init():
	_io_manager = AsyncIOManager.new()

func _exit() -> void:
	if auto_save and _modified:
		save_config()

## 加载配置
## [param callback] 回调函数
func load_config(callback: Callable = func(_success: bool): pass) -> void:
	_io_manager.read_file_async(
		config_path,
		true,
		false,
		"",
		func(success: bool, result: Variant):
			if success:
				_config = result
			else:
				_config = default_config.duplicate(true)
			_modified = false
			config_loaded.emit()
			callback.call(success)
	)

## 保存配置
## [param callback] 回调函数
func save_config(callback: Callable = func(_success: bool): pass) -> void:
	_io_manager.write_file_async(
		config_path,
		_config,
		true,
		false,
		"",
		func(success: bool, _result: Variant):
			if success:
				_modified = false
				config_saved.emit()
			callback.call(success)
	)

## 重置配置
## [param callback] 回调函数
func reset_config(callback: Callable = func(_success: bool): pass) -> void:
	_config = default_config.duplicate(true)
	_modified = true
	config_reset.emit()
	
	if auto_save:
		save_config(callback)
	else:
		callback.call(true)

## 设置配置值
## [param section] 配置段
## [param key] 键
## [param value] 值
func set_value(section: String, key: String, value: Variant) -> void:
	if not _config.has(section):
		_config[section] = {}
	_config[section][key] = value
	_modified = true
	
	if auto_save:
		save_config()

## 获取配置值
## [param section] 配置段
## [param key] 键
## [param default_value] 默认值
## [return] 值
func get_value(section: String, key: String, default_value: Variant = null) -> Variant:
	if _config.has(section) and _config[section].has(key):
		return _config[section][key]
	elif default_config.has(section) and default_config[section].has(key):
		return default_config[section][key]
	return default_value

## 删除配置值
## [param section] 配置段
## [param key] 键
func erase_value(section: String, key: String) -> void:
	if _config.has(section):
		_config[section].erase(key)
		_modified = true
		
		if auto_save:
			save_config()

## 获取配置段
## [param section] 配置段
## [return] 配置段
func get_section(section: String) -> Dictionary:
	return _config.get(section, {}).duplicate()
