extends AbilityEffectNode
class_name AbilityEffectControlNode

## 控制节点：负责控制多个子节点的执行流程
@export var children: Array[AbilityEffectNode]

func add_child(child: AbilityEffectNode) -> void:
	children.append(child)

func remove_child(child: AbilityEffectNode) -> void:
	children.erase(child)

func clear_children() -> void:
	children.clear()

func get_node(effect_name: StringName) -> AbilityEffectNode:
	for child in children:
		if child.effect_name == effect_name:
			return child
		if child.has_method("get_node"):
			var node = child.get_node(effect_name)
			if node:
				return node
	return null
