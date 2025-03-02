extends RefCounted
class_name PresentationHandler

## 表现处理器接口

func handle_effect(_config: Dictionary, _context: Dictionary) -> void:
	pass


func _get_targets(config: Dictionary, context: Dictionary) -> Array[Node]:
	# 获取目标节点
	var targets : Array[Node] = []
	var target_type : String = config.get("target", "target")
	if target_type == "actor":
		targets.append(context.get("caster"))
	elif target_type == "target":
		targets.append_array(context.get("targets", []))
		var target : Node = context.get("target", null)
		if target:
			targets.append(target)
	return targets
