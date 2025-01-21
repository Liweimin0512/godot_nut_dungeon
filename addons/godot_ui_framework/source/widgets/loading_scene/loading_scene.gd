extends Control
class_name LoadingScreen

signal loading_completed

@export_group("Loading Settings")
@export var min_display_time: float = 0.5
@export var fade_duration: float = 0.3
@export var show_progress: bool = true
@export var show_tips: bool = true

@export_group("Visual Settings")
@export var progress_bar_style: StyleBox
@export var background_color: Color = Color(0.1, 0.1, 0.1, 1.0)

var _progress: float = 0.0
var _start_time: float = 0.0
var _is_loading: bool = false
var _tips: Array[String] = []
var _current_tip: int = 0

@onready var _progress_bar: ProgressBar = $ProgressBar
@onready var _tip_label: Label = $TipLabel
@onready var _background: ColorRect = $Background

func _ready() -> void:
    setup_loading_screen()
    hide()

func setup_loading_screen() -> void:
    _background.color = background_color
    if progress_bar_style:
        _progress_bar.add_theme_stylebox_override("fill", progress_bar_style)
    
    _progress_bar.visible = show_progress
    _tip_label.visible = show_tips

func show_loading_screen() -> void:
    _is_loading = true
    _start_time = Time.get_ticks_msec() / 1000.0
    _progress = 0.0
    _update_progress_display()
    
    if show_tips:
        _cycle_tips()
    
    show()
    modulate.a = 0.0
    create_tween().tween_property(self, "modulate:a", 1.0, fade_duration)

func hide_loading_screen() -> void:
    var current_time = Time.get_ticks_msec() / 1000.0
    var elapsed_time = current_time - _start_time
    
    if elapsed_time < min_display_time:
        await get_tree().create_timer(min_display_time - elapsed_time).timeout
    
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", 0.0, fade_duration)
    await tween.finished
    
    hide()
    _is_loading = false
    loading_completed.emit()

func set_progress(value: float) -> void:
    _progress = clamp(value, 0.0, 1.0)
    _update_progress_display()
    
    if _progress >= 1.0:
        hide_loading_screen()

func set_tips(tips: Array[String]) -> void:
    _tips = tips
    _current_tip = 0
    if show_tips and _tips.size() > 0:
        _tip_label.text = _tips[0]

func _update_progress_display() -> void:
    if show_progress:
        _progress_bar.value = _progress * 100

func _cycle_tips() -> void:
    if _tips.size() == 0:
        return
    
    create_tween().tween_property(_tip_label, "modulate:a", 0.0, 0.5)
    await get_tree().create_timer(0.5).timeout
    
    _current_tip = (_current_tip + 1) % _tips.size()
    _tip_label.text = _tips[_current_tip]
    
    create_tween().tween_property(_tip_label, "modulate:a", 1.0, 0.5)
    
    if _is_loading:
        await get_tree().create_timer(3.0).timeout
        _cycle_tips()