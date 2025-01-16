@tool
extends EditorPlugin

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_autoload_singleton("EventBus", "res://addons/li_framework/event_bus.gd")
	#add_autoload_singleton("DatatableManager", "res://addons/li_framework/datatable_manager/datatable_manager.gd")
	add_autoload_singleton("UIManager", "res://addons/li_framework/UIframework/UImanager.gd")

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
