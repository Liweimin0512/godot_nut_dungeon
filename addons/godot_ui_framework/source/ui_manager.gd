extends Node

## UI管理器
## 负责管理UI的生命周期、状态转换和资源加载
##
## 使用示例：
## ```gdscript
## # 注册UI类型
## UIManager.register_ui_type(main_menu_type)
## # 显示UI
## await UIManager.show_ui("main_menu")
## # 隐藏UI
## await UIManager.hide_ui("main_menu")
## ```

## UI状态枚举
enum UIState { NONE, OPENING, OPENED, CLOSING, CLOSED }

## 资源管理器
var resource_manager : UIResourceManager:
	get:
		return get_module("resource") as UIResourceManager
	set(value):
		push_error("resource_manager is read-only")
## Widget管理器
var widget_manager : UIWidgetManager:
	get:
		return get_module("widget") as UIWidgetManager
	set(value):
		push_error("widget_manager is read-only")
## Scene管理器
var scene_manager : UISceneManager:
	get:
		return get_module("scene") as UISceneManager
	set(value):
		push_error("scene_manager is read-only")
## Theme管理器
var theme_manager : UIThemeManager:
	get:
		return get_module("theme") as UIThemeManager
	set(value):
		push_error("theme_manager is read-only")
## Transition管理器
var transition_manager : UITransitionManager:
	get:
		return get_module("transition") as UITransitionManager
	set(value):
		push_error("transition_manager is read-only")
## Adaptation管理器
var adaptation_manager : UIAdaptationManager:
	get:
		return get_module("adaptation") as UIAdaptationManager
	set(value):
		push_error("adaptation_manager is read-only")
## Localization管理器
var localization_manager : UILocalizationManager:
	get:
		return get_module("localization") as UILocalizationManager
	set(value):
		push_error("localization_manager is read-only")

## 模块类映射
var _module_types : Dictionary[StringName, Script] = {
	"resource": UIResourceManager,
	"scene": UISceneManager,
	"widget": UIWidgetManager,
	"theme": UIThemeManager,
	"transition": UITransitionManager,
	"adaptation": UIAdaptationManager,
	"localization": UILocalizationManager,
}
## 模块实例
var _modules = {}
## 界面分组
var _groups: Dictionary[String, UIGroupComponent] = {}

## 设置分组
func set_group(group_name: StringName, group: UIGroupComponent) -> void:
	_groups[group_name] = group

## 获取分组
func get_group(group_name: StringName) -> UIGroupComponent:
	assert(_groups.has(group_name), "不是有效的UI组")
	return _groups[group_name]

## 移除分组
func remove_group(group_name: StringName) -> bool:
	return _groups.erase(group_name)

## 判断是否存在分组
func has_group(group_name: StringName) -> bool:
	return _groups.has(group_name)

func get_scene_component(scene: Control) -> UISceneComponent:
	return scene.get_node_or_null("UISceneComponent")

func get_widget_component(widget: Control) -> UIWidgetComponent:
	return widget.get_node_or_null("UIWidgetComponent")

func get_group_component(group: Control) -> UIGroupComponent:
	return group.get_node_or_null("UIGroupComponent")

func is_widget(widget: Control) -> bool:
	return widget.has_node("UIWidgetComponent")

func is_group(group: Control) -> bool:
	return group.has_node("UIGroupComponent")

func is_scene(scene: Control) -> bool:
	return scene.has_node("UISceneComponent")

## 获取模块实例
func get_module(module_id: String) -> RefCounted:
	if not is_module_enabled(module_id):
		push_warning("Attempting to access disabled module: %s" % module_id)
		return null
	
	# 如果模块已创建，直接返回
	if _modules.has(module_id):
		return _modules[module_id]
	
	# 按需创建模块
	var module = _create_module(module_id)
	if module:
		_modules[module_id] = module
	
	return module

## 检查模块是否启用
func is_module_enabled(module_id: String) -> bool:
	return ProjectSettings.get_setting("godot_ui_framework/modules/" + module_id + "/enabled", false)

## 创建模块实例
func _create_module(module_id: StringName) -> RefCounted:
	if not _module_types.has(module_id):
		push_error("Unknown module: %s" % module_id)
		return null
	return _module_types[module_id].new()
