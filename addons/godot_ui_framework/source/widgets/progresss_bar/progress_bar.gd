extends Control
class_name CustomProgressBar

@export_group("Progress Settings")
@export var show_text: bool = true
@export var format: String = "{value}/{max_value}"
@export var smooth_change: bool = true
@export var change_duration: float = 0.3

func set_progress(current: float, maximum: float) -> void:
    # 设置进度
    pass