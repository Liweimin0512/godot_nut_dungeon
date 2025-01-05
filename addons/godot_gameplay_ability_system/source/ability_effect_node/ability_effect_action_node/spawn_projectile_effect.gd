extends AbilityEffectActionNode
class_name SpawnProjectileEffect

## 生成投射物节点

## 投射物场景
@export var projectile_scene: PackedScene
@export var speed: float
## 起始位置挂点类型
@export var start_position_type: String = "body"
## 目标位置挂点类型
@export var target_position_type: String = "body"

func _perform_visual(context: Dictionary) -> STATUS:
    # 获取施法单位
    var caster = context.get("caster")
    # 获取起始单位
    var source = context.get("source")
    if source == null:
        source = caster
    # 获取起始位置
    var start_pos : Vector2
    if source.has_method("get_cast_position"):
        start_pos = source.get_cast_position(start_position_type)
    else:
        GASLogger.error("SpawnProjectileEffect: source has no get_cast_position method")
        return STATUS.FAILURE
    var target = context.get("target")
    if target == null:
        GASLogger.error("SpawnProjectileEffect: target is null")
        return STATUS.FAILURE
    var target_pos: Vector2
    if target.has_method("get_cast_position"):
        target_pos = target.get_cast_position(target_position_type)
    else:
        GASLogger.error("SpawnProjectileEffect: target has no get_cast_position method")
        return STATUS.FAILURE
    
    var projectile = projectile_scene.instantiate()
    caster.add_child(projectile)
    if projectile.has_method("setup"):
        projectile.setup({
            "caster": caster,
            "source": source,
            "target": target,
            "start_position": start_pos,
            "target_position": target_pos,
            "speed": speed,
        })
    else:
        GASLogger.error("SpawnProjectileEffect: projectile has no setup method")
        return STATUS.FAILURE
    
    # 等待投射物到达目标位置
    await projectile.hit_target
    
    return STATUS.SUCCESS