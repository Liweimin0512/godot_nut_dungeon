extends Node
class_name Serializable

## 序列化组件，需要序列化的节点应该添加这个组件作为子节点

## 信号
signal before_serialize
signal after_serialize
signal before_deserialize
signal after_deserialize

## 序列化数据提供者接口，父节点需要实现这个接口
## 返回需要序列化的数据
func _get_serialize_data() -> Dictionary:
	if get_parent().has_method("_get_serialize_data"):
		return get_parent()._get_serialize_data()
	push_error("Parent node does not implement _get_serialize_data()")
	return {}

## 反序列化数据接收者接口，父节点需要实现这个接口
## 处理反序列化的数据
func _set_serialize_data(data: Dictionary) -> void:
	if get_parent().has_method("_set_serialize_data"):
		get_parent()._set_serialize_data(data)
	else:
		push_error("Parent node does not implement _set_serialize_data()")

## 序列化对象为字典
func serialize() -> Dictionary:
	before_serialize.emit()
	var data = _get_serialize_data()
	data["__version"] = get_version()
	after_serialize.emit()
	return data

## 从字典反序列化对象
func deserialize(data: Dictionary) -> void:
	if not validate_data(data):
		push_error("Invalid serialization data")
		return
	
	before_deserialize.emit()
	_set_serialize_data(data)
	after_deserialize.emit()

## 获取序列化版本号（用于处理不同版本的存档）
func get_version() -> String:
	if get_parent().has_method("get_serialize_version"):
		return get_parent().get_serialize_version()
	return "1.0.0"

## 验证序列化数据是否有效
func validate_data(data: Dictionary) -> bool:
	if not data.has("__version"):
		return false
	return true
