extends Control
class_name Toast

@export_group("Toast Settings")
@export var duration: float = 2.0
@export var fade_time: float = 0.3
@export var position_offset: Vector2 = Vector2(0, 100)

enum ToastType {
    INFO,
    SUCCESS,
    WARNING,
    ERROR
}

static func show(message: String, type: ToastType = ToastType.INFO) -> void:
    # 显示提示消息
    pass