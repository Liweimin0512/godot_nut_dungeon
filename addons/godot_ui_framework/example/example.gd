extends Control

@export var _ui_scene_types: Array[UISceneType] = [
	preload("res://addons/godot_ui_framework/example/resource/inventory_window_type.tres")
]
@export var _ui_widget_types: Array[UIWidgetType] = [
	preload("res://addons/godot_ui_framework/example/resource/inventory_slot_type.tres"), 
]

# 使用示例
func _ready() -> void:
	# 注册UI类型
	for ui_scene_type in _ui_scene_types:
		UIManager.scene_manager.register_scene_type(ui_scene_type)
	for ui_widget_type in _ui_widget_types:
		UIManager.widget_manager.register_widget_type(ui_widget_type)

func _on_button_inventory_pressed() -> void:
	UIManager.scene_manager.create_scene(&"inventory_window")
