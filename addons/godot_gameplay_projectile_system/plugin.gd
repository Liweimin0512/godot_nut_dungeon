@tool
extends EditorPlugin

const PLUGIN_NAME = "GodotGameplayProjectileSystem"
const PLUGIN_VERSION = "0.1.0"

func _enter_tree() -> void:
	# 注册自定义类型
	_register_custom_types()
	# 将projectile_system注册为自动加载的单例
	add_autoload_singleton("ProjectileSystem", "res://addons/godot_gameplay_projectile_system/auto/projectile_system.gd")
	print("{0} v{1} initialized".format([PLUGIN_NAME, PLUGIN_VERSION]))

func _exit_tree() -> void:
	# 移除自定义类型
	_unregister_custom_types()
	print("{0} v{1} unloaded".format([PLUGIN_NAME, PLUGIN_VERSION]))

func _register_custom_types() -> void:
	# 注册核心组件
	# add_custom_type("AbilityComponent", "Node", preload("source/ability_component.gd"), preload("icons/ability_component.svg"))
	pass

func _unregister_custom_types() -> void:
	# 移除注册的类型
	# remove_custom_type("AbilityComponent")
	pass
