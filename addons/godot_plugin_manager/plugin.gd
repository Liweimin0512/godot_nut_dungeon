@tool
extends EditorPlugin

const PluginManagerScene = preload("res://addons/godot_plugin_manager/scenes/plugin_manager.tscn")
var plugin_manager_instance: Control = null

func _enter_tree() -> void:
	# 创建插件管理器实例
	plugin_manager_instance = PluginManagerScene.instantiate()
	# 添加到编辑器的底部面板
	add_control_to_bottom_panel(plugin_manager_instance, "Plugin Manager")
	
	# 初始化命令行工具
	if not Engine.is_editor_hint():
		return
	add_tool_menu_item("Install Plugin Dependencies", _install_dependencies)

func _exit_tree() -> void:
	# 清理插件管理器
	if plugin_manager_instance:
		remove_control_from_bottom_panel(plugin_manager_instance)
		plugin_manager_instance.queue_free()
	
	if not Engine.is_editor_hint():
		return
	remove_tool_menu_item("Install Plugin Dependencies")

func _install_dependencies() -> void:
	plugin_manager_instance.install_all_dependencies()
