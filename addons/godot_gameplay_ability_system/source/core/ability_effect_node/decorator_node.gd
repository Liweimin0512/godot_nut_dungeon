class_name DecoratorNode
extends AbilityEffectNode

## 装饰器节点：修改或增强单个子节点的行为
@export var child: AbilityEffectNode

func set_child(new_child: AbilityEffectNode) -> void:
    child = new_child

func clear_child() -> void:
    child = null