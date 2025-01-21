@tool
extends EditorPlugin

const SETTING_PATH = "godot_ui_framework/modules/"
const MODULES = {
	"resource": {
		"name": "Resource Manager",
		"description": "管理UI资源的加载和缓存",
		"default": true
	},
	"scene": {
		"name": "Scene Manager",
		"description": "管理UI场景的生命周期",
		"default": true
	},
	"widget": {
		"name": "Widget Manager",
		"description": "管理可重用UI控件",
		"default": true
	},
	"theme": {
		"name": "Theme Manager",
		"description": "管理UI主题和样式",
		"default": true
	},
	"debug": {
		"name": "Debug Tools",
		"description": "UI调试工具",
		"default": true
	}
}

func _enter_tree() -> void:
	# 添加项目设置
	_add_module_settings()
	add_autoload_singleton("UIManager", "res://addons/godot_ui_framework/source/ui_manager.gd")


func _exit_tree() -> void:
	# 移除项目设置
	_remove_module_settings()	
	remove_autoload_singleton("UIManager")

## 添加模块设置到项目设置
func _add_module_settings() -> void:
	# 添加模块分类
	_ensure_project_settings_category()
	
	# 为每个模块添加设置
	for module_id in MODULES:
		var module = MODULES[module_id]
		var setting_name = SETTING_PATH + module_id + "/enabled"
		
		if not ProjectSettings.has_setting(setting_name):
			ProjectSettings.set_setting(setting_name, module.default)
			
			# 设置属性
			ProjectSettings.set_initial_value(setting_name, module.default)
			ProjectSettings.add_property_info({
				"name": setting_name,
				"type": TYPE_BOOL,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": module.description
			})

## 移除模块设置
func _remove_module_settings() -> void:
	for module_id in MODULES:
		var setting_name = SETTING_PATH + module_id + "/enabled"
		if ProjectSettings.has_setting(setting_name):
			ProjectSettings.set_setting(setting_name, null)

## 确保项目设置中有我们的分类
func _ensure_project_settings_category() -> void:
	# 添加UI框架分类
	ProjectSettings.set_setting("godot_ui_framework/", {})
	ProjectSettings.set_setting("godot_ui_framework/modules/", {})
	
	# 设置为可见
	ProjectSettings.add_property_info({
		"name": "godot_ui_framework/",
		"type": TYPE_NIL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "ui_framework_category"
	})
