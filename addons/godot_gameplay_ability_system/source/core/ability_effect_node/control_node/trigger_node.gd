class_name TriggerNode
extends ControlNode

enum TriggerType {
    ON_DAMAGED,
    ON_HEAL,
    ON_KILL,
    ON_ATTRIBUTE_CHANGED,
    ON_RESOURCE_CHANGED,
    ON_BUFF_APPLIED,
    ON_BUFF_REMOVED,
    CUSTOM
}

## 触发类型
@export var trigger_type: TriggerType
## 是否持续触发
@export var persistent: bool = true
## 触发次数限制 (-1为无限)
@export var trigger_count: int = -1
## 自定义触发条件
@export var custom_condition: Callable

var _current_triggers: int = 0
var _registered: bool = false

func _execute(context: Dictionary) -> STATUS:
    if not _registered:
        _register_trigger(context)
        _registered = true
    return STATUS.SUCCESS

func _register_trigger(context: Dictionary) -> void:
    var target = context.get("target", context.get("source"))
    if not target: return
    
    match trigger_type:
        TriggerType.ON_DAMAGED:
            target.damaged.connect(_handle_trigger.bind(context))
        TriggerType.ON_ATTRIBUTE_CHANGED:
            target.attribute_changed.connect(_handle_trigger.bind(context))
        # ... 其他触发类型注册

func _handle_trigger(trigger_data: Dictionary, original_context: Dictionary) -> void:
    # 检查触发次数
    if trigger_count > 0 and _current_triggers >= trigger_count:
        _unregister_trigger()
        return
        
    # 检查自定义条件
    if custom_condition.is_valid() and not custom_condition.call(trigger_data):
        return
        
    # 合并上下文
    var new_context = original_context.duplicate()
    new_context.merge(trigger_data)
    
    # 执行所有子节点
    for child in children:
        child.execute(new_context)
    
    _current_triggers += 1
    
    # 检查是否需要解除注册
    if not persistent or (trigger_count > 0 and _current_triggers >= trigger_count):
        _unregister_trigger()

func _unregister_trigger() -> void:
    # 清理所有信号连接
    if _registered:
        # 解除信号连接的逻辑
        _registered = false

func reset() -> void:
    _current_triggers = 0
    if not _registered and persistent:
        _register_trigger(context)