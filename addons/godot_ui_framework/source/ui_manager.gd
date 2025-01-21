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
		return _resource_manager
	set(value):
		push_error("resource_manager is read-only")
## Widget管理器
var widget_manager : UIWidgetManager:
	get:
		return _widget_manager
	set(value):
		push_error("widget_manager is read-only")
## 分组管理器
var group_manager : UIGroupManager:
	get:
		return _group_manager
	set(value):
		push_error("group_manager is read-only")

## 资源管理器
var _resource_manager: UIResourceManager
## Widget管理器
var _widget_manager: UIWidgetManager
## 界面分组管理器
var _group_manager: UIGroupManager

## 界面分组
var _groups: Dictionary[String, UIGroupComponent] = {}

func _ready() -> void:
	_resource_manager = UIResourceManager.new()
	_widget_manager = UIWidgetManager.new()
	_group_manager = UIGroupManager.new()

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