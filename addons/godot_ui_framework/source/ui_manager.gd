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
var _group: Dictionary = {}
## 界面数据
var _ui_types: Dictionary = {}
## UI状态追踪
var _ui_states: Dictionary = {}
## UI导航历史 (按组存储)
var _navigation_history: Dictionary = {}

## UI组
var _group: Dictionary[StringName, UIGroupComponent]

## UI状态改变
signal ui_state_changed(ui_id: StringName, state: UIState)
## 过渡动画开始
signal ui_transition_started(ui_id: StringName)
## 过渡动画结束
signal ui_transition_completed(ui_id: StringName)

func _ready() -> void:
	_resource_manager = UIResourceManager.new()
	_widget_manager = UIWidgetManager.new()
	_group_manager = UIGroupManager.new()

## 设置分组
func set_group(group_name: StringName, control: Node) -> void:
	_group[group_name] = control

## 获取分组
func get_group(group_name: StringName) -> Node:
	assert(_group.has(group_name), "不是有效的UI组")
	return _group[group_name]

## 移除分组
func remove_group(group_name: StringName) -> bool:
	return _group.erase(group_name)

## 判断是否存在分组
func has_group(group_name: StringName) -> bool:
	return _group.has(group_name)

## 更新导航历史
func _update_navigation_history(groupID: StringName, ui_id: StringName) -> void:
	if not _navigation_history.has(groupID):
		_navigation_history[groupID] = []
	var history: Array = _navigation_history[groupID]
	history.append(ui_id)
	# 限制历史记录长度
	if history.size() > 10:
		history.pop_front()

## 导航返回
func navigate_back(groupID: StringName) -> void:
	if not _navigation_history.has(groupID):
		return
		
	var history: Array = _navigation_history[groupID]
	if history.size() < 2:
		return
		
	# 移除当前界面
	history.pop_back()
	# 获取上一个界面
	var previous_ui = history.pop_back()
	if previous_ui:
		await show_ui(previous_ui)
