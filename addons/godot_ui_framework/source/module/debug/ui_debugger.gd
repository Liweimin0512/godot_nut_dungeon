@tool
extends Control
class_name UIDebugger

## UI调试器模块
## 提供UI层级查看、性能监控和状态检查功能

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
        if visible:
            _update_debug_view()

## 性能监控配置
@export_group("Performance Monitor")
@export var monitor_interval: float = 1.0  # 监控间隔
@export var history_length: int = 60       # 历史记录长度

## 是否启用调试器（仅编辑器模式有效）
var is_enabled: bool:
    get:
        if not Engine.is_editor_hint():
            return false
        return ProjectSettings.get_setting("project/debug/enable_ui_debugger", true)

var _hierarchy_viewer: UIHierarchyViewer
var _performance_monitor: UIPerformanceMonitor
var _state_inspector: UIStateInspector

func _ready() -> void:
    if not is_enabled:
        queue_free()
        return

    setup_debug_views()
    _setup_shortcuts()
    
    # 注册到UI管理器
    UIManager.register_debugger(self)

func _exit_tree() -> void:
    if UIManager.is_module_enabled("debug"):
        UIManager.unregister_debugger(self)

func _setup_shortcuts() -> void:
    # 设置快捷键
    var shortcut = Shortcut.new()
    var event = InputEventKey.new()
    event.keycode = KEY_F3
    shortcut.events.append(event)
    
    # 添加快捷键动作
    var action = "toggle_debug_view"
    if not InputMap.has_action(action):
        InputMap.add_action(action)
        InputMap.action_add_event(action, event)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("toggle_debug_view"):
        show_debug_info = !show_debug_info
    
func setup_debug_views() -> void:
    # 创建UI层级查看器
    _hierarchy_viewer = UIHierarchyViewer.new()
    add_child(_hierarchy_viewer)
    _hierarchy_viewer.node_selected.connect(_on_node_selected)
    
    # 创建性能监视器
    _performance_monitor = UIPerformanceMonitor.new()
    _performance_monitor.monitor_interval = monitor_interval
    _performance_monitor.history_length = history_length
    add_child(_performance_monitor)
    
    # 创建状态检查器
    _state_inspector = UIStateInspector.new()
    add_child(_state_inspector)
    
    _update_debug_view()

## 更新调试视图
func _update_debug_view() -> void:
    if not is_instance_valid(_hierarchy_viewer) or \
       not is_instance_valid(_performance_monitor) or \
       not is_instance_valid(_state_inspector):
        return
        
    _hierarchy_viewer.visible = debug_mode == DebugMode.HIERARCHY
    _performance_monitor.visible = debug_mode == DebugMode.PERFORMANCE
    _state_inspector.visible = debug_mode == DebugMode.STATE

func _on_node_selected(node: Control) -> void:
    if is_instance_valid(_state_inspector):
        _state_inspector.inspect_node(node)

## 获取当前调试模式
func get_debug_mode() -> DebugMode:
    return debug_mode

## 设置调试模式
func set_debug_mode(mode: DebugMode) -> void:
    debug_mode = mode

## 获取性能监控数据
func get_performance_metrics() -> Dictionary:
    return _performance_monitor.get_metrics() if is_instance_valid(_performance_monitor) else {}
