# source/debug/ui_performance_monitor.gd
extends Control
class_name UIPerformanceMonitor

var _metrics: Dictionary = {
    "fps": [],
    "draw_calls": [],
    "node_count": [],
    "ui_updates": []
}

var _graph: Control
var _labels: Dictionary = {}

func _ready() -> void:
    setup_monitor()
    # 开始监控
    create_timer(monitor_interval).timeout.connect(update_metrics)

func setup_monitor() -> void:
    # 创建图表
    _graph = Line2D.new()
    add_child(_graph)
    
    # 创建标签
    for metric in _metrics.keys():
        var label = Label.new()
        add_child(label)
        _labels[metric] = label

func update_metrics() -> void:
    var performance = Performance.get_monitor()
    
    # 更新指标
    _metrics.fps.push_back(Engine.get_frames_per_second())
    _metrics.draw_calls.push_back(performance.get_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME))
    _metrics.node_count.push_back(performance.get_monitor(Performance.OBJECT_NODE_COUNT))
    
    # 限制历史记录长度
    for metric in _metrics.keys():
        if _metrics[metric].size() > history_length:
            _metrics[metric].pop_front()
    
    _update_graph()
    _update_labels()