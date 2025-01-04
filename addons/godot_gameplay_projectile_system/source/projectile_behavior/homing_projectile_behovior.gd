extends ProjectileBehavior
class_name HomingProjectileBehavior

## 追踪投射物行为

## 转向速度
var turn_speed: float = 100.0

## 更新投射物位置
func update(projectile_data: Dictionary, delta: float) -> void:
    var target = projectile_data.target
    if not is_instance_valid(target):
        return
        
    var direction = projectile_data.velocity.normalized()
    var to_target = (target.global_position - projectile_data.position).normalized()
    
    # 计算转向
    var angle = direction.angle_to(to_target)
    var rotation = sign(angle) * min(abs(angle), turn_speed * delta)
    
    # 更新速度和位置
    projectile_data.velocity = projectile_data.velocity.rotated(rotation)
    projectile_data.position += projectile_data.velocity * delta
