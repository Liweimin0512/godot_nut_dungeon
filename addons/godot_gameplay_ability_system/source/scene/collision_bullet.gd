extends Node2D
class_name CollisionBullet

## 基于碰撞检测的子弹

@export var hit_area : Area2D

## 击中目标
signal hit_target(target: Node2D)

func _ready() -> void:
	hit_area.area_entered.connect(_on_hit_area_entered)
	hit_area.body_entered.connect(_on_hit_body_entered)

func _on_hit_area_entered(area: Area2D) -> void:
	hit_target.emit(area)

func _on_hit_body_entered(body: Node2D) -> void:
	hit_target.emit(body)