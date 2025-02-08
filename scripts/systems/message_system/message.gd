@tool
extends RefCounted
class_name Message

## 消息基类
## 所有具体消息类型都应该继承此类

## 消息类型
enum MessageType {
    NONE,           # 无类型
    ANIMATION,      # 动画消息
    SOUND,          # 音效消息
    PROPERTY,       # 属性变化
    STATE,          # 状态变化
    CUSTOM          # 自定义消息
}

#region 属性
## 消息类型
var type: MessageType = MessageType.NONE

## 消息ID
var id: StringName

## 消息数据
var data: Dictionary

## 是否阻塞（阻塞消息会等待完成才继续下一个）
var blocking: bool = false

## 完成回调
var on_complete: Callable
#endregion

func _init(p_id: StringName, p_type: MessageType = MessageType.NONE, p_data: Dictionary = {}, p_blocking: bool = false) -> void:
    id = p_id
    type = p_type
    data = p_data
    blocking = p_blocking

## 执行消息
## [param target] 消息接收者
## [returns] 是否执行成功
func execute(target: Node) -> bool:
    return false  # 基类不实现具体逻辑

## 取消消息
func cancel() -> void:
    pass  # 基类不实现具体逻辑

## 完成消息
func complete() -> void:
    if on_complete:
        on_complete.call()
