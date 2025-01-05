@tool
extends EditorPlugin

const PLUGIN_NAME = "GodotGameplayAbilitySystem"
const PLUGIN_VERSION = "0.1.0"

func _enter_tree() -> void:
	# 注册自定义类型
	_register_custom_types()
	print("{0} v{1} initialized".format([PLUGIN_NAME, PLUGIN_VERSION]))

func _exit_tree() -> void:
	# 移除自定义类型
	_unregister_custom_types()
	print("{0} v{1} unloaded".format([PLUGIN_NAME, PLUGIN_VERSION]))

func _register_custom_types() -> void:
	# 注册核心组件
	add_custom_type("AbilityComponent", "Node", preload("source/ability_component.gd"), preload("icons/ability_component.svg"))
	add_custom_type("Ability", "Resource", preload("source/core/ability.gd"), preload("icons/ability.svg"))
	add_custom_type("AbilityAttribute", "Resource", preload("source/core/ability_attribute.gd"), preload("icons/attribute.svg"))

func _unregister_custom_types() -> void:
	# 移除注册的类型
	remove_custom_type("AbilityComponent")
	remove_custom_type("Ability")
	remove_custom_type("AbilityAttribute")
