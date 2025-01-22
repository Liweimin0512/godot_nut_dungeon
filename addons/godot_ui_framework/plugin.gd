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
	"transition": {
		"name": "Transition Manager",
		"description": "管理UI过渡效果",
		"default": true
	},
	"adaptation": {
		"name": "Adaptation Manager",
		"description": "管理UI适配",
		"default": true
	},
	"localization": {
		"name": "Localization Manager",
		"description": "管理UI本地化",
		"default": true
	}
}

func _enter_tree() -> void:
	# 确保项目设置分类存在
	_ensure_project_settings_category()
	# 添加项目设置
	_add_module_settings()
	# 保存设置
	ProjectSettings.save()
	# 添加自动加载单例
	add_autoload_singleton("UIManager", "res://addons/godot_ui_framework/source/ui_manager.gd")

func _exit_tree() -> void:
	# 移除项目设置
	_remove_module_settings()
	# 保存设置
	ProjectSettings.save()
	# 移除自动加载单例
	remove_autoload_singleton("UIManager")

## 添加模块设置
func _add_module_settings() -> void:
	for module_id in MODULES:
		var module = MODULES[module_id]
		var setting_name = SETTING_PATH + module_id + "/enabled"
		if not ProjectSettings.has_setting(setting_name):
			ProjectSettings.set_setting(setting_name, module.default)
			ProjectSettings.add_property_info({
				"name": setting_name,
				"type": TYPE_BOOL,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": module.description
			})
	if not ProjectSettings.has_setting("godot_ui_framework/debug/enable_ui_debugger"):
		ProjectSettings.set_setting("godot_ui_framework/debug/enable_ui_debugger", true)

## 移除模块设置
func _remove_module_settings() -> void:
	for module_id in MODULES:
		var setting_name = SETTING_PATH + module_id + "/enabled"
		if ProjectSettings.has_setting(setting_name):
			ProjectSettings.set_setting(setting_name, null)
	if ProjectSettings.has_setting("godot_ui_framework/debug/enable_ui_debugger"):
		ProjectSettings.set_setting("godot_ui_framework/debug/enable_ui_debugger", null)

## 确保项目设置中有我们的分类
func _ensure_project_settings_category() -> void:
	if not ProjectSettings.has_setting("godot_ui_framework/modules"):
		ProjectSettings.set_setting("godot_ui_framework/modules", {})
		ProjectSettings.set_as_basic("godot_ui_framework/modules", true)
		ProjectSettings.add_property_info({
			"name": "godot_ui_framework/modules",
			"type": TYPE_DICTIONARY,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "UI Framework Modules"
		})
