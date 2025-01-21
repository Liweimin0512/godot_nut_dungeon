@tool
extends Control
class_name UIDebugger

## 调试模式枚举
enum DebugMode {
    HIERARCHY,  # UI层级
    PERFORMANCE,# 性能监控
    STATE       # 状态查看
}

## 当前调试模式
@export var debug_mode: DebugMode = DebugMode.HIERARCHY:
    set(value):
        debug_mode = value
        _update_debug_view()

## 是否显示调试信息
@export var show_debug_info: bool = true:
    set(value):
        show_debug_info = value
        visible = value

## 性能监控配置
@export_group("Performance Monitor")
@export var monitor_interval: float = 1.0  # 监控间隔
@export var history_length: int = 60       # 历史记录长度

var _hierarchy_tree: Tree
var _performance_view: Control
var _state_inspector: Control
var _current_selected: Control

func _ready() -> void:
    setup_debug_views()
    # 设置快捷键
    var shortcut = Shortcut.new()
    shortcut.events.append(InputEventKey.new())
    shortcut.events[0].keycode = KEY_F3
    
func setup_debug_views() -> void:
    # 创建UI层级树
    _setup_hierarchy_tree()
    # 创建性能监视器
    _setup_performance_monitor()
    # 创建状态检查器
    _setup_state_inspector()
    
    _update_debug_view()

## 更新调试视图
func _update_debug_view() -> void:
    _hierarchy_tree.visible = debug_mode == DebugMode.HIERARCHY
    _performance_view.visible = debug_mode == DebugMode.PERFORMANCE
    _state_inspector.visible = debug_mode == DebugMode.STATE
