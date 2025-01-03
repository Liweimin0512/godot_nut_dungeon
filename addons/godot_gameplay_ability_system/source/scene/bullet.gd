extends Node2D
class_name Bullet

## 子弹，技能系统表现的一部分

## 子弹的等待释放时间
@export var wait_time:float = 0.2
## 子弹的释放时间
@export var cast_time : float = 0.6
## 子弹的目标位置
var target_point : Vector2
## 子弹动画
@export var sprite_frames : SpriteFrames
@export var offset : Vector2 = Vector2(0, -50)

func _ready() -> void:
	self.position += offset
	$AnimatedSprite2D.sprite_frames = sprite_frames
	await get_tree().create_timer(wait_time).timeout
	$AnimatedSprite2D.play("default")
	create_tween().tween_property(self, "global_position", target_point + offset, cast_time)
	await get_tree().create_timer(cast_time).timeout
	get_parent().remove_child(self)
	queue_free()

func _process(_delta: float) -> void:
	look_at(target_point)
