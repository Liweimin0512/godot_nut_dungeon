extends Resource
class_name UITransition

## 过渡类型
enum TRANSITION_TYPE {
	NONE,           # 无过渡效果
	FADE,           # 淡入淡出
	SLIDE_LEFT,     # 从左滑入
	SLIDE_RIGHT,    # 从右滑入
	SLIDE_UP,       # 从上滑入
	SLIDE_DOWN,     # 从下滑入
	SCALE,          # 缩放
	CUSTOM          # 自定义
}

## 过渡时间（秒）
@export var duration: float = 0.3
## 过渡类型
@export var transition_type: TRANSITION_TYPE = TRANSITION_TYPE.FADE
## 缓动类型
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT
## 过渡曲线
@export var trans_type: Tween.TransitionType = Tween.TRANS_CUBIC

## 执行打开过渡动画
func apply_open_transition(ui: Control) -> void:
	match transition_type:
		TRANSITION_TYPE.NONE:
			ui.modulate.a = 1.0
		TRANSITION_TYPE.FADE:
			_apply_fade_in(ui)
		TRANSITION_TYPE.SLIDE_LEFT:
			_apply_slide_in(ui, Vector2.LEFT)
		TRANSITION_TYPE.SLIDE_RIGHT:
			_apply_slide_in(ui, Vector2.RIGHT)
		TRANSITION_TYPE.SLIDE_UP:
			_apply_slide_in(ui, Vector2.UP)
		TRANSITION_TYPE.SLIDE_DOWN:
			_apply_slide_in(ui, Vector2.DOWN)
		TRANSITION_TYPE.SCALE:
			_apply_scale_in(ui)
		TRANSITION_TYPE.CUSTOM:
			_apply_custom_open(ui)

## 执行关闭过渡动画
func apply_close_transition(ui: Control) -> void:
	match transition_type:
		TRANSITION_TYPE.NONE:
			ui.modulate.a = 0.0
		TRANSITION_TYPE.FADE:
			_apply_fade_out(ui)
		TRANSITION_TYPE.SLIDE_LEFT:
			_apply_slide_out(ui, Vector2.LEFT)
		TRANSITION_TYPE.SLIDE_RIGHT:
			_apply_slide_out(ui, Vector2.RIGHT)
		TRANSITION_TYPE.SLIDE_UP:
			_apply_slide_out(ui, Vector2.UP)
		TRANSITION_TYPE.SLIDE_DOWN:
			_apply_slide_out(ui, Vector2.DOWN)
		TRANSITION_TYPE.SCALE:
			_apply_scale_out(ui)
		TRANSITION_TYPE.CUSTOM:
			_apply_custom_close(ui)

## 淡入效果
func _apply_fade_in(ui: Control) -> void:
	ui.modulate.a = 0.0
	var tween = ui.create_tween()
	tween.set_ease(ease_type)
	tween.set_trans(trans_type)
	tween.tween_property(ui, "modulate:a", 1.0, duration)

## 淡出效果
func _apply_fade_out(ui: Control) -> void:
	var tween = ui.create_tween()
	tween.set_ease(ease_type)
	tween.set_trans(trans_type)
	tween.tween_property(ui, "modulate:a", 0.0, duration)

## 滑入效果
func _apply_slide_in(ui: Control, direction: Vector2) -> void:
	var screen_size = ui.get_viewport_rect().size
	var start_pos = ui.position + direction * screen_size
	ui.position = start_pos
	var tween = ui.create_tween()
	tween.set_ease(ease_type)
	tween.set_trans(trans_type)
	tween.tween_property(ui, "position", Vector2.ZERO, duration)

## 滑出效果
func _apply_slide_out(ui: Control, direction: Vector2) -> void:
	var screen_size = ui.get_viewport_rect().size
	var end_pos = ui.position + direction * screen_size
	var tween = ui.create_tween()
	tween.set_ease(ease_type)
	tween.set_trans(trans_type)
	tween.tween_property(ui, "position", end_pos, duration)

## 缩放入场效果
func _apply_scale_in(ui: Control) -> void:
	ui.scale = Vector2.ZERO
	ui.pivot_offset = ui.size / 2
	var tween = ui.create_tween()
	tween.set_ease(ease_type)
	tween.set_trans(trans_type)
	tween.tween_property(ui, "scale", Vector2.ONE, duration)

## 缩放出场效果
func _apply_scale_out(ui: Control) -> void:
	ui.pivot_offset = ui.size / 2
	var tween = ui.create_tween()
	tween.set_ease(ease_type)
	tween.set_trans(trans_type)
	tween.tween_property(ui, "scale", Vector2.ZERO, duration)

## 自定义打开过渡效果
## 子类可以重写此方法实现自定义过渡效果
func _apply_custom_open(ui: Control) -> void:
	pass

## 自定义关闭过渡效果
## 子类可以重写此方法实现自定义过渡效果
func _apply_custom_close(ui: Control) -> void:
	pass
