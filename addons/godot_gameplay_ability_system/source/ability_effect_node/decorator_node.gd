extends AbilityEffectNode
class_name DecoratorNode

## 装饰器节点：修改或增强单个子节点的行为

@export var child: AbilityEffectNode

func set_child(new_child: AbilityEffectNode) -> void:
	child = new_child

func clear_child() -> void:
	child = null

func _revoke() -> STATUS:
	return await child.revoke() if child else STATUS.SUCCESS

func get_node(name: StringName) -> AbilityEffectNode:
	if effect_name == name:
		return self
	return child.get_node(name) if child else null
