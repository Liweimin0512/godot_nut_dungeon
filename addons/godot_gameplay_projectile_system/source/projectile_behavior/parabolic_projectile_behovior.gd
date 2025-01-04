class_name ParabolicProjectileBehavior
extends ProjectileBehavior

## 抛物线运动
var gravity: float = 980.0

func update(projectile_data: Dictionary, delta: float) -> void:
    projectile_data.velocity.y += gravity * delta
    projectile_data.position += projectile_data.velocity * delta