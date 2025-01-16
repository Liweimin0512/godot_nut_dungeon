@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_autoload_singleton(
		"DatatableManager", 
		"res://addons/li_data_manager/data_table_manager.gd"
		)

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
