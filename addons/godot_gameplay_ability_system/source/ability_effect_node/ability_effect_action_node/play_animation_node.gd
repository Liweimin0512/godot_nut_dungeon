extends AbilityEffectActionNode
class_name PlayAnimationNode

## 播放动画节点

## 动画名称
@export var animation_name: String
## 混合时间
@export var blend_time: float = 0.2
## 自定义速度
@export var custom_speed: float = 1.0
## 是否等待完成
@export var wait_for_completion: bool = false
## 播放动画的单位
@export_enum("caster", "target")
var animation_unit_type: String = "caster"

func _perform_action(context: Dictionary) -> STATUS:
    var unit = context.get(animation_unit_type)
    if not unit or not unit.has_method("play_animation"):
        GASLogger.error("PlayAnimationNode unit is null or unit has no play_animation method")
        return STATUS.FAILURE

    if wait_for_completion:
        # 等待动画完成
        await unit.play_animation(animation_name, blend_time, custom_speed)
    else:
        unit.play_animation(animation_name, blend_time, custom_speed)
        
    return STATUS.SUCCESS