extends Node2D

@export var _ui_types: Array[UIType]

# 使用示例
func _ready() -> void:	
	# 打开UI
	await UIManager.show_ui("main_menu", {"initial_tab": "inventory"})
	
	# 使用导航
	UIManager.navigate_to("character_status")
	await UIManager.navigate_back()
