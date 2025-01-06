extends DecoratorNode
class_name DecoratorRandomTargetNode

## 目标类型，self: 自身，ally: 友军，enemy: 敌军，all: 所有
@export_enum("self", "ally", "enemy", "all") var target_type : String = "self"

## 是否排除当前目标
@export var exclude_current: bool = false

func _execute(context: Dictionary) -> STATUS:
    var enemies = context.get("enemies")
    var allies = context.get("allies")
    var caster = context.get("caster")
    var target = context.get("target")
    var target_pool : Array = []
    if target_type == "self":
        target_pool.append(caster)
    elif target_type == "ally":
        target_pool.append_array(allies)
    elif target_type == "enemy":
        target_pool.append_array(enemies)
    elif target_type == "all":
        target_pool.append_array(allies + enemies)
    if target_pool.size() == 0:
        GASLogger.error("DecoratorRandomTargetNode: target pool is empty")
        return STATUS.FAILURE
    if exclude_current and target:
        target_pool.erase(target)
    if target:
        context["last_target"] = target
    target = target_pool.pick_random()
    var _context = context.duplicate()
    _context["target"] = target
    return await child.execute(_context) if child else STATUS.FAILURE