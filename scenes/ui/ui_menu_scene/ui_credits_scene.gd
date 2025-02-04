extends Control

@onready var _button_back = %ButtonBack

func _ready() -> void:
	_button_back.pressed.connect(_on_button_back_pressed)

func _on_button_back_pressed() -> void:
	queue_free()
