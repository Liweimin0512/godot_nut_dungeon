extends Control
class_name BaseWindow

@export_group("Window Settings")
@export var title: String = ""
@export var show_title_bar: bool = true
@export var closeable: bool = true
@export var draggable: bool = true
@export var resizable: bool = false
@export var min_size: Vector2 = Vector2(100, 100)
@export var remember_position: bool = false

signal closed
signal dragged
signal resized

var _is_dragging: bool = false
var _drag_start_pos: Vector2
var _window_start_pos: Vector2

func _ready() -> void:
    setup_window()
    load_window_state()

func setup_window() -> void:
    # 设置窗口基本布局
    pass

func _on_close_pressed() -> void:
    save_window_state()
    closed.emit()

func save_window_state() -> void:
    if remember_position:
        # 保存窗口位置等状态
        pass