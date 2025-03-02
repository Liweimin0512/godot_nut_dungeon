extends RefCounted
class_name CombatEvent

## 战斗事件类，用于管理战斗系统中的事件
## 提供事件的发布和订阅功能

var _event_name: StringName
var _event_bus: CoreSystem.EventBus:
	get:
		return CoreSystem.event_bus

func _init(p_event_name: StringName) -> void:
	# 添加命名空间前缀，避免事件名冲突
	_event_name = "CombatSystem." + p_event_name

## 发送事件
## [param payload] 事件数据
func push(payload: Variant = []) -> void:
	_event_bus.push_event(_event_name, payload)

## 订阅事件
## [param callback] 回调函数
func subscribe(callback: Callable) -> void:
	_event_bus.subscribe(_event_name, callback)

## 取消订阅事件
## [param callback] 要取消的回调函数
func unsubscribe(callback: Callable) -> void:
	_event_bus.unsubscribe(_event_name, callback)

## 获取事件名称
func get_event_name() -> StringName:
	return _event_name
