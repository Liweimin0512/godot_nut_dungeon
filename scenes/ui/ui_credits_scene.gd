extends Control

@onready var _button_back = %ButtonBack
@onready var ui_scene_component: UISceneComponent = $UISceneComponent

func _ready() -> void:
	_button_back.pressed.connect(_on_button_back_pressed)

func _on_button_back_pressed() -> void:
	ui_scene_component.close()
