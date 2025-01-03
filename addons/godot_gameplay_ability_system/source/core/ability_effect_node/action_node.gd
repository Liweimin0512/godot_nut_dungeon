class_name ActionNode
extends AbilityEffectNode

## 执行节点：执行具体的游戏效果

func validate_parameters() -> bool:
    return true

func _execute(context: Dictionary) -> STATUS:
    if not validate_parameters():
        return STATUS.FAILURE
    return _perform_action(context)

func _perform_action(_context: Dictionary) -> STATUS:
    return STATUS.SUCCESS