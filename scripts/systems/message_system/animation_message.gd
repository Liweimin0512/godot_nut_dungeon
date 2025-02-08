@tool
extends Message
class_name AnimationMessage

## 动画消息
## 用于播放动画

func _init(p_id: StringName, p_data: Dictionary = {}, p_blocking: bool = true) -> void:
    super._init(p_id, Message.MessageType.ANIMATION, p_data, p_blocking)

func execute(target: Node) -> bool:
    if not target or not target.has_node("AnimationPlayer"):
        return false
    
    var anim_player = target.get_node("AnimationPlayer")
    if not anim_player:
        return false
    
    var anim_name = data.get("animation", "")
    if anim_name.is_empty() or not anim_player.has_animation(anim_name):
        return false
    
    # 连接动画完成信号
    if blocking:
        if not anim_player.animation_finished.is_connected(_on_animation_finished):
            anim_player.animation_finished.connect(_on_animation_finished)
    
    # 播放动画
    anim_player.play(anim_name)
    return true

func cancel() -> void:
    super.cancel()
    # 可以在这里添加取消动画的逻辑

func _on_animation_finished(_anim_name: StringName) -> void:
    complete()
