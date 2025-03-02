extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var target_position : Vector2
var duration : float

func _ready() -> void:
	var tween := create_tween()
	tween.tween_property(self, "global_position", target_position, duration)
	await tween.finished
	animated_sprite_2d.play(&"on_hit")
	await animated_sprite_2d.animation_finished
	get_parent().remove_child(self)
	queue_free()
