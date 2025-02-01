extends Serializable
class_name SaveData

## 存档数据类

## 存档元数据
var metadata: Dictionary = {
	"version": "1.0.0",			## 存档版本号
	"timestamp": 0,				## 存档时间戳
	"save_name": "",			## 存档名称
	"play_time": 0,				## 游戏时间
	"screenshot": "",			## 截图
}

## 游戏数据
var game_data: Dictionary = {}

## 序列化
func serialize() -> Dictionary:
	return {
		"metadata": metadata,
		"game_data": game_data,
	}

## 反序列化
func deserialize(data: Dictionary) -> void:
	if data.has("metadata"):
		metadata = data.metadata
	if data.has("game_data"):
		game_data = data.game_data

## 更新元数据
func update_metadata(save_name: String = "", screenshot: String = "") -> void:
	metadata.version = get_version()
	metadata.timestamp = Time.get_unix_time_from_system()
	if save_name:
		metadata.save_name = save_name
	if screenshot:
		metadata.screenshot = screenshot

## 设置游戏数据
func set_game_data(key: String, value: Variant) -> void:
	game_data[key] = value

## 获取游戏数据
func get_game_data(key: String, default: Variant = null) -> Variant:
	return game_data.get(key, default)

## 移除游戏数据
func remove_game_data(key: String) -> void:
	game_data.erase(key)

## 清除所有游戏数据
func clear_game_data() -> void:
	game_data.clear()

## 获取存档时间戳
func get_timestamp() -> int:
	return metadata.timestamp

## 获取存档名称
func get_save_name() -> String:
	return metadata.save_name

## 获取游戏时间
func get_play_time() -> int:
	return metadata.play_time

## 设置游戏时间
func set_play_time(time: int) -> void:
	metadata.play_time = time

## 获取截图路径
func get_screenshot() -> String:
	return metadata.screenshot
