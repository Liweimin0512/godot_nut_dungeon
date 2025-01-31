@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_autoload_singleton("EventBus", "res://addons/godot_core_system/event_bus.gd")

func _exit_tree() -> void:
	remove_autoload_singleton("EventBus")
