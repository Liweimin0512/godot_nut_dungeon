@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("ItemSystem", "res://addons/godot_item_system/scripts/item_system.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("ItemSystem")
