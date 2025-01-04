extends RefCounted
class_name ProjectileBehavior

## 投射物行为基类

func update(delta: float) -> void:
    pass

func get_next_position(current_position: Vector2, data: Dictionary) -> Vector2:
    return current_position



