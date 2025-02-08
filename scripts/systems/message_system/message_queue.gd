@tool
extends Node
class_name MessageQueue

## 消息队列
## 管理消息的排队和执行

#region 信号
## 消息开始执行
signal message_started(message: Message)
## 消息执行完成
signal message_completed(message: Message)
## 消息队列清空
signal queue_empty
#endregion

#region 内部变量
var _queue: Queue = Queue.new()
var _current_message: Message
var _target: Node
var _is_processing: bool = false
var _auto_process: bool = true
#endregion

#region 生命周期
func _ready() -> void:
    set_process(false)

func _process(_delta: float) -> void:
    if _auto_process:
        process_message()
#endregion

#region 公共方法
## 设置消息接收者
## [param target] 接收消息的节点
func set_target(target: Node) -> void:
    _target = target

## 添加消息
## [param message] 要添加的消息
func enqueue(message: Message) -> void:
    _queue.enqueue(message)
    if not _is_processing and _auto_process:
        set_process(true)

## 添加多个消息
## [param messages] 要添加的消息列表
func enqueue_multiple(messages: Array[Message]) -> void:
    for message in messages:
        enqueue(message)

## 清空队列
func clear() -> void:
    if _current_message:
        _current_message.cancel()
    _queue.clear()
    _current_message = null
    _is_processing = false
    set_process(false)
    queue_empty.emit()

## 设置自动处理
## [param value] 是否自动处理
func set_auto_process(value: bool) -> void:
    _auto_process = value
    set_process(value and not _queue.is_empty)

## 处理下一条消息
func process_message() -> void:
    if _is_processing or not _target:
        return
    
    if _queue.is_empty:
        set_process(false)
        queue_empty.emit()
        return
    
    _is_processing = true
    _current_message = _queue.dequeue()
    
    if _current_message:
        message_started.emit(_current_message)
        
        if _current_message.blocking:
            # 阻塞消息需要等待完成
            _current_message.on_complete = _on_message_complete
        
        if _current_message.execute(_target):
            if not _current_message.blocking:
                # 非阻塞消息立即完成
                _on_message_complete()
        else:
            # 执行失败，继续下一个
            _on_message_complete()

## 获取当前消息
## [returns] 当前正在执行的消息
func get_current_message() -> Message:
    return _current_message

## 获取队列大小
## [returns] 队列中的消息数量
func get_queue_size() -> int:
    return _queue.size
#endregion

#region 内部方法
## 处理消息完成
func _on_message_complete() -> void:
    if _current_message:
        message_completed.emit(_current_message)
        _current_message.complete()
        _current_message = null
    
    _is_processing = false
    
    if not _queue.is_empty:
        process_message()
    else:
        queue_empty.emit()
#endregion
