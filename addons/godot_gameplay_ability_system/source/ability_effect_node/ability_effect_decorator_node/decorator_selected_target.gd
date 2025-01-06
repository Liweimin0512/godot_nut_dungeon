extends DecoratorNode
class_name DecoratorSelectedTargetNode

## 目标类型，self: 自身，ally: 友军，enemy: 敌军，all: 所有
@export_enum("self", "ally", "enemy", "all") var target_type : String = "self"

func _execute(context: Dictionary) -> STATUS:
    var enemies = context.get("enemies")
    var allies = context.get("allies")
    var caster = context.get("caster")
    var target = null
    if target_type == "self":
        target = caster
    elif target_type == "ally":
        target = allies.pick_random()
    elif target_type == "enemy":
        target = enemies.pick_random()
    elif target_type == "all":
        target = (allies + enemies).pick_random()
    var _context = context.duplicate()
    _context["target"] = target
    return await child.execute(_context) if child else STATUS.FAILURE