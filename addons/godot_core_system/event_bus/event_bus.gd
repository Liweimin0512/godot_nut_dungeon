extends Node
class_name EventBus

## 事件优先级枚举
enum Priority {
	LOW = 0,
	NORMAL = 1,
	HIGH = 2,
}

## 事件订阅信息
class Subscription:
	## 回调函数
	var callback: Callable
	## 优先级
	var priority: Priority
	## 是否只触发一次
	var once: bool
	## 过滤器
	var filter: Callable
	
	func _init(cb: Callable, p: Priority, o: bool, f: Callable = func(_p): return true) -> void:
		callback = cb
		priority = p
		once = o
		filter = f

## 事件订阅字典 {事件名: [Subscription]}
var _subscriptions: Dictionary = {}
## 事件历史记录
var _event_history: Array[Dictionary] = []
## 是否记录事件历史
@export var enable_history: bool = false
## 历史记录最大长度
@export var max_history_length: int = 100
## 调试模式
@export var debug_mode: bool = false

## 信号：事件被推送时触发
signal event_pushed(event_name: String, payload: Array)
## 信号：事件处理完成时触发
signal event_handled(event_name: String, payload: Array)

## 推送事件
func push_event(event_name: String, payload = null, immediate: bool = true) -> void:
	if not payload is Array:
		payload = [payload]
	
	if debug_mode:
		print("[EventBus] Pushing event: %s with payload: %s" % [event_name, payload])
	
	if enable_history:
		_record_event(event_name, payload)
	
	event_pushed.emit(event_name, payload)
	
	if not _subscriptions.has(event_name):
		if debug_mode:
			print("[EventBus] No subscribers for event: %s" % event_name)
		return
	
	# 按优先级排序订阅者
	var subscribers = _subscriptions[event_name].duplicate()
	subscribers.sort_custom(func(a, b): return a.priority > b.priority)
	
	# 收集需要移除的一次性订阅
	var to_remove: Array[Subscription] = []
	
	# 处理事件
	for sub in subscribers:
		if sub.filter.call(payload):
			if immediate:
				sub.callback.callv(payload)
			else:
				call_deferred("_deferred_call", sub.callback, payload)
			
			if sub.once:
				to_remove.append(sub)
	
	# 移除一次性订阅
	for sub in to_remove:
		_subscriptions[event_name].erase(sub)
	
	event_handled.emit(event_name, payload)

## 订阅事件
func subscribe(
	event_name: String, 
	callback: Callable, 
	priority: Priority = Priority.NORMAL,
	once: bool = false,
	filter: Callable = func(_p): return true
) -> void:
	if not _subscriptions.has(event_name):
		_subscriptions[event_name] = []
	
	# 检查是否已存在相同的回调
	for sub in _subscriptions[event_name]:
		if sub.callback == callback:
			if debug_mode:
				print("[EventBus] Callback already subscribed to event: %s" % event_name)
			return
	
	var subscription = Subscription.new(callback, priority, once, filter)
	_subscriptions[event_name].append(subscription)
	
	if debug_mode:
		print("[EventBus] Subscribed to event: %s with priority: %s" % [event_name, priority])

## 取消订阅事件
func unsubscribe(event_name: String, callback: Callable) -> void:
	if not _subscriptions.has(event_name):
		return
	
	var index = -1
	for i in range(_subscriptions[event_name].size()):
		if _subscriptions[event_name][i].callback == callback:
			index = i
			break
	
	if index != -1:
		_subscriptions[event_name].remove_at(index)
		if debug_mode:
			print("[EventBus] Unsubscribed from event: %s" % event_name)

## 订阅一次性事件
func subscribe_once(
	event_name: String, 
	callback: Callable, 
	priority: Priority = Priority.NORMAL,
	filter: Callable = func(_p): return true
) -> void:
	subscribe(event_name, callback, priority, true, filter)

## 取消订阅所有事件
func unsubscribe_all(callback: Callable) -> void:
	for event_name in _subscriptions:
		unsubscribe(event_name, callback)

## 清除所有订阅
func clear_subscriptions() -> void:
	_subscriptions.clear()
	if debug_mode:
		print("[EventBus] All subscriptions cleared")

## 获取事件订阅者数量
func get_subscriber_count(event_name: String) -> int:
	if not _subscriptions.has(event_name):
		return 0
	return _subscriptions[event_name].size()

## 获取事件历史记录
func get_event_history() -> Array[Dictionary]:
	return _event_history.duplicate()

## 清除事件历史记录
func clear_event_history() -> void:
	_event_history.clear()

## 记录事件
func _record_event(event_name: String, payload: Array) -> void:
	var event = {
		"timestamp": Time.get_unix_time_from_system(),
		"event_name": event_name,
		"payload": payload
	}
	_event_history.push_front(event)
	
	if _event_history.size() > max_history_length:
		_event_history.pop_back()

## 延迟调用回调
func _deferred_call(callback: Callable, payload: Array) -> void:
	callback.callv(payload)
