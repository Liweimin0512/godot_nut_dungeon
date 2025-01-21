# rotate_scale_transition.gd
extends UITransition

func _apply_custom_open(ui: Control) -> void:
    ui.scale = Vector2.ZERO
    ui.rotation = PI
    ui.pivot_offset = ui.size / 2
    
    var tween = ui.create_tween()
    tween.set_parallel(true)
    tween.set_ease(ease_type)
    tween.set_trans(trans_type)
    tween.tween_property(ui, "scale", Vector2.ONE, duration)
    tween.tween_property(ui, "rotation", 0.0, duration)

func _apply_custom_close(ui: Control) -> void:
    ui.pivot_offset = ui.size / 2
    
    var tween = ui.create_tween()
    tween.set_parallel(true)
    tween.set_ease(ease_type)
    tween.set_trans(trans_type)
    tween.tween_property(ui, "scale", Vector2.ZERO, duration)
    tween.tween_property(ui, "rotation", -PI, duration)