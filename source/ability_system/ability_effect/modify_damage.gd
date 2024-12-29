extends AbilityEffect
class_name ModifyDamageEffect

## 处理伤害，通常只在受到伤害前或造成伤害后有效
@export_enum("value", "percentage")
var modify_type : String = "value"
@export var modify_value : float = 0.1


func apply_effect(context: Dictionary = {}) -> void:
	var targets : Array = _get_targets(context)
	for target in targets:
		var damage = context.get("damage")
		if modify_type == "value":
			damage.value += modify_value
		else:
			damage.value *= (1+ modify_value)
	super(context)

func _description_getter() -> String:
	var modify_name : String = "%" if modify_type == "percentage" else "点"
	var modify : String = "增加" if modify_value > 0 else "减少"
	return "使伤害{0}{1}{3}".format([modify, modify_value, modify_name])
