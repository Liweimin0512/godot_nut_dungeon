@tool
extends Control
class_name UIPerformanceMonitor

## UI性能监控器
## 监控UI相关的性能指标，包括FPS、绘制调用次数、节点数量等

## 监控间隔
var monitor_interval: float = 1.0:
    set(value):
        monitor_interval = value
        if _update_timer:
            _update_timer.wait_time = value

## 历史记录长度
var history_length: int = 60:
    set(value):
        history_length = value
        _trim_metrics()

var _metrics: Dictionary = {
    "fps": [],           # 帧率
    "draw_calls": [],    # 绘制调用
    "node_count": [],    # 节点数量
    "ui_updates": []     # UI更新次数
}

var _graph: Line2D
var _labels: Dictionary = {}
var _update_timer: Timer

func _ready() -> void:
    setup_monitor()
    _setup_timer()

func _exit_tree() -> void:
    if _update_timer:
        _update_timer.queue_free()
    _update_timer = null

func setup_monitor() -> void:
    # 创建图表
    _graph = Line2D.new()
    _graph.width = 2.0
    _graph.default_color = Color.GREEN
    add_child(_graph)
    
    # 设置图表大小
    custom_minimum_size = Vector2(300, 200)
    
    # 创建标签
    for metric in _metrics.keys():
        var label = Label.new()
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        add_child(label)
        _labels[metric] = label
        
    # 初始化布局
    _update_layout()

func _setup_timer() -> void:
    _update_timer = Timer.new()
    _update_timer.wait_time = monitor_interval
    _update_timer.timeout.connect(update_metrics)
    add_child(_update_timer)
    _update_timer.start()

## 更新性能指标
func update_metrics() -> void:
    if not visible:
        return
        
    var performance = Performance.get_monitor(Performance.TIME_FPS)
    
    # 更新指标
    _metrics.fps.push_back(Engine.get_frames_per_second())
    _metrics.draw_calls.push_back(performance.get_monitor(Performance.OBJECT_DRAW_CALLS))
    _metrics.node_count.push_back(performance.get_monitor(Performance.OBJECT_NODE_COUNT))
    _metrics.ui_updates.push_back(performance.get_monitor(Performance.OBJECT_PROPERTY_UPDATES))
    
    # 限制历史记录长度
    _trim_metrics()
    
    # 更新显示
    _update_graph()
    _update_labels()

## 更新图表
func _update_graph() -> void:
    if not is_instance_valid(_graph):
        return
        
    var points = PackedVector2Array()
    var values = _metrics.fps  # 默认显示FPS
    var max_value = values.max() if values else 1.0
    
    for i in values.size():
        var x = i * size.x / (history_length - 1)
        var y = size.y * (1.0 - values[i] / max_value)
        points.push_back(Vector2(x, y))
    
    _graph.points = points

## 更新标签
func _update_labels() -> void:
    for metric in _metrics.keys():
        var label = _labels.get(metric)
        if label and _metrics[metric].size() > 0:
            var current = _metrics[metric][-1]
            var avg = _calculate_average(_metrics[metric])
            label.text = "%s: %d (avg: %.1f)" % [metric.capitalize(), current, avg]

## 计算平均值
func _calculate_average(values: Array) -> float:
    if values.is_empty():
        return 0.0
    return values.reduce(func(accum, number): return accum + number, 0.0) / values.size()

## 限制指标历史记录长度
func _trim_metrics() -> void:
    for metric in _metrics.keys():
        while _metrics[metric].size() > history_length:
            _metrics[metric].pop_front()

## 更新布局
func _update_layout() -> void:
    if not is_instance_valid(_graph):
        return
        
    _graph.position = Vector2.ZERO
    _graph.size = size
    
    var y_offset = 0
    for label in _labels.values():
        label.position = Vector2(size.x - 150, y_offset)
        label.size = Vector2(150, 20)
        y_offset += 25

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        _update_layout()

## 获取性能指标数据
func get_metrics() -> Dictionary:
    return _metrics.duplicate(true)