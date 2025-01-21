@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("UIManager", "res://addons/godot_ui_framework/source/UIManager.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("UIManager")
