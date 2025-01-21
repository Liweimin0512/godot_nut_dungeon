extends Container
class_name AdaptiveContainer

@export var adapt_children: bool = true
@export var reference_size: Vector2 = Vector2(1920, 1080)

func _ready() -> void:
    UIAdaptationManager.scale_changed.connect(_on_scale_changed)
    resized.connect(_on_container_resized)

func _on_scale_changed(new_scale: float) -> void:
    if adapt_children:
        for child in get_children():
            if child is Control:
                _adapt_control(child, new_scale)

func _adapt_control(control: Control, scale: float) -> void:
    # 调整控件大小和位置
    control.custom_minimum_size = control.custom_minimum_size * scale
    control.position = control.position * scale