extends Node2D

@onready var ui_group_component: UIGroupComponent = %UIGroupComponent

func _ready() -> void:
	ui_group_component.show_scene("ui_menu_scene")
