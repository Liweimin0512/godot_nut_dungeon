class_name RepeatDecoratorNode
extends DecoratorNode

## 重复装饰器：重复执行子节点

@export var repeat_count: int = 1
@export var repeat_interval: float = 0.0

func _execute(context: Dictionary) -> STATUS:
    for i in repeat_count:
        var status = child.execute(context)
        if status == STATUS.FAILURE:
            return STATUS.FAILURE
        if repeat_interval > 0 and i < repeat_count - 1:
            await context.get("tree").create_timer(repeat_interval).timeout
    return STATUS.SUCCESS