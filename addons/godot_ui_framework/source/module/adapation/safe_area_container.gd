# source/adaptation/safe_area_container.gd
extends Container
class_name SafeAreaContainer

@export var margin: Vector2 = Vector2(50, 50)

func _ready() -> void:
    UIAdaptationManager.safe_area_changed.connect(_on_safe_area_changed)

func _on_safe_area_changed(new_safe_area: Rect2) -> void:
    # 调整内容到安全区域
    var safe_rect = new_safe_area
    safe_rect = safe_rect.grow_individual(-margin.x, -margin.y, -margin.x, -margin.y)
    custom_minimum_size = safe_rect.size
    position = safe_rect.position