extends Node2D
class_name ProximityBullet

## 基于距离的子弹

## 击中距离
@export var hit_distance : float = 10
## 移动速度
@export var move_speed : float = 300
## 目标
var target: Node2D

## 击中目标
signal hit_target(target: Node2D)

func _process(delta: float) -> void:
    var distance = global_position.distance_to(target.global_position)
    if distance <= hit_distance:
        hit_target.emit(target)
        queue_free()
    else:
        move_to_target(delta)

## 移动到目标
func move_to_target(delta: float) -> void:
    global_position = global_position.move_toward(target.global_position, move_speed * delta)
