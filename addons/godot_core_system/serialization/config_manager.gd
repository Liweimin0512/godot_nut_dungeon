extends Node
class_name ConfigManager

## 配置管理器

## 信号
signal config_loaded
signal config_saved
signal config_reset

## 配置文件路径
const CONFIG_DIR = "user://config"
const CONFIG_FILE = "config.cfg"

## 默认配置
var _default_config: Dictionary = {
	"video": {
		"fullscreen": false,
		"vsync": true,
		"resolution": Vector2i(1920, 1080),
		"window_mode": 0,
	},
	"audio": {
		"master_volume": 1.0,
		"music_volume": 1.0,
		"sfx_volume": 1.0,
		"voice_volume": 1.0,
	},
	"game": {
		"language": "en",
		"difficulty": 1,
		"auto_save": true,
		"auto_save_interval": 300,
	},
	"controls": {
		"mouse_sensitivity": 1.0,
		"invert_y": false,
		"gamepad_enabled": true,
	}
}

## 当前配置
var _config: Dictionary = {}
## 配置文件路径
var _config_path: String

## IO管理器
var _io_manager: AsyncIOManager = null

func _init() -> void:
	_config_path = CONFIG_DIR.path_join(CONFIG_FILE)
	reset_to_default()

func _ready() -> void:
	# 确保配置目录存在
	DirAccess.make_dir_recursive_absolute(CONFIG_DIR)
	
	# 初始化IO管理器
	_io_manager = AsyncIOManager.new()
	add_child(_io_manager)
	_io_manager.io_completed.connect(_on_io_completed)
	_io_manager.io_error.connect(_on_io_error)
	
	# 加载配置
	load_config_async()

## 获取配置值
func get_value(section: String, key: String, default = null) -> Variant:
	if not _config.has(section) or not _config[section].has(key):
		return default
	return _config[section][key]

## 设置配置值
func set_value(section: String, key: String, value: Variant) -> void:
	if not _config.has(section):
		_config[section] = {}
	_config[section][key] = value

## 异步保存配置
func save_config_async(callback: Callable = func(_success: bool): pass) -> void:
	_io_manager.write_async(
		_config_path,
		JSON.stringify(_config),
		false,
		false,
		"",
		func(success: bool, _result: Variant):
			if success:
				config_saved.emit()
			callback.call(success)
	)

## 异步加载配置
func load_config_async(callback: Callable = func(_success: bool): pass) -> void:
	if not FileAccess.file_exists(_config_path):
		save_config_async(callback)
		return
	
	_io_manager.read_async(
		_config_path,
		false,
		false,
		"",
		func(success: bool, result: Variant):
			if success and result:
				var parse_result = JSON.parse_string(result)
				if parse_result != null:
					_config = parse_result
					_validate_config()
					config_loaded.emit()
			callback.call(success)
	)

## IO完成回调
func _on_io_completed(result: Variant) -> void:
	pass

## IO错误回调
func _on_io_error(error: String) -> void:
	push_error("Config IO error: " + error)

## 重置为默认配置
func reset_to_default() -> void:
	_config = _default_config.duplicate(true)
	config_reset.emit()

## 获取所有配置
func get_all_config() -> Dictionary:
	return _config.duplicate(true)

## 设置多个配置值
func set_values(values: Dictionary) -> void:
	for section in values:
		if values[section] is Dictionary:
			for key in values[section]:
				set_value(section, key, values[section][key])

## 验证配置有效性
func _validate_config() -> void:
	# 确保所有默认配置项都存在
	for section in _default_config:
		if not _config.has(section):
			_config[section] = {}
		
		for key in _default_config[section]:
			if not _config[section].has(key):
				_config[section][key] = _default_config[section][key]

## 应用视频配置
func apply_video_config() -> void:
	var fullscreen = get_value("video", "fullscreen", false)
	var vsync = get_value("video", "vsync", true)
	var resolution = get_value("video", "resolution", Vector2i(1920, 1080))
	var window_mode = get_value("video", "window_mode", 0)
	
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		match window_mode:
			0: # 窗口模式
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			1: # 无边框窗口
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			2: # 最大化
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED)
	if not fullscreen:
		DisplayServer.window_set_size(resolution)

## 应用音频配置
func apply_audio_config() -> void:
	var master_volume = get_value("audio", "master_volume", 1.0)
	var music_volume = get_value("audio", "music_volume", 1.0)
	var sfx_volume = get_value("audio", "sfx_volume", 1.0)
	var voice_volume = get_value("audio", "voice_volume", 1.0)
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Voice"), linear_to_db(voice_volume))
