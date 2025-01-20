@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_autoload_singleton("DataManager", "res://addons/li_data_manager/source/data_manager.gd")

func _exit_tree() -> void:
	remove_autoload_singleton("DataManager")
