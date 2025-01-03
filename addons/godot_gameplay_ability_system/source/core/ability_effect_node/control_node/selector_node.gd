class_name SelectorNode
extends ControlNode

## 选择节点：执行子节点直到一个成功

func _execute(context: Dictionary) -> STATUS:
    for child in children:
        var status = child.execute(context)
        if status != STATUS.FAILURE:
            return status
    return STATUS.FAILURE