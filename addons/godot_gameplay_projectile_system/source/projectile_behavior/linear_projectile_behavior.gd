extends ProjectileBehavior
class_name LinearProjectileBehavior

## 直线运动
func update(delta: float) -> void:
    projectile_data.position += projectile_data.velocity * delta

## 线性投射物行为
func get_next_position(current_position: Vector2, data: Dictionary) -> Vector2:
    return current_position + data.velocity * delta
