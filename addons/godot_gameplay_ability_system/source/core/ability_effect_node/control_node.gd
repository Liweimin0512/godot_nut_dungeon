class_name ControlNode
extends AbilityEffectNode

## 控制节点：负责控制多个子节点的执行流程
@export var children: Array[AbilityEffectNode]

func add_child(child: AbilityEffectNode) -> void:
    children.append(child)

func remove_child(child: AbilityEffectNode) -> void:
    children.erase(child)

func clear_children() -> void:
    children.clear()