extends AbilityEffect
class_name ApplyTagEffect

## 对目标应用某种标签

@export_enum("stun") var tag_type: String = "stun"

func _apply(context: Dictionary = {}) -> void:
	var targets : Array = _get_targets(context)
	for target in targets:
		target.add_to_group(tag_type)
	super(context)

## 移除效果
func _remove(context: Dictionary = {}) -> void:
	var targets : Array = _get_targets(context)
	for target in targets:
		target.remove_from_group(tag_type)
	super(context)

func _description_getter() -> String:
	var _tag_name : String
	match tag_type:
		"stun":
			_tag_name
	return "对目标释放{0}".format([_tag_name])
