extends RefCounted
class_name UIAdaptationManager

## 缩放模式枚举
enum ScaleMode {
	FIT,        # 适应屏幕（保持比例）
	FILL,       # 填充屏幕（可能裁剪）
	STRETCH,    # 拉伸（不保持比例）
	PIXEL       # 像素精确（整数倍缩放）
}

## 参考分辨率
var reference_resolution: Vector2 = Vector2(1920, 1080)
## 最小缩放比例
var min_scale: float = 0.5
## 最大缩放比例
var max_scale: float = 2.0
## 是否保持宽高比
var maintain_aspect_ratio: bool = true
## 缩放模式
var scale_mode: ScaleMode = ScaleMode.FIT

## 当前UI缩放比例
var current_scale: float = 1.0
## 安全区域
var safe_area: Rect2
## 实际分辨率
var actual_resolution: Vector2

## 分辨率改变信号
signal resolution_changed(new_resolution: Vector2)
## 缩放比例改变信号
signal scale_changed(new_scale: float)
## 安全区域改变信号
signal safe_area_changed(new_safe_area: Rect2)

func _ready() -> void:
	# 监听窗口变化
	UIManager.get_tree().root.size_changed.connect(_on_viewport_size_changed)
	# 初始化
	_update_safe_area()
	_update_ui_scale()

## 更新UI缩放
func _update_ui_scale() -> void:
	var viewport_size = UIManager.get_viewport().get_visible_rect().size
	var scale_x = viewport_size.x / reference_resolution.x
	var scale_y = viewport_size.y / reference_resolution.y
	
	match scale_mode:
		ScaleMode.FIT:
			current_scale = min(scale_x, scale_y)
		ScaleMode.FILL:
			current_scale = max(scale_x, scale_y)
		ScaleMode.STRETCH:
			current_scale = min(scale_x, scale_y)
		ScaleMode.PIXEL:
			current_scale = floor(min(scale_x, scale_y))
	
	# 限制缩放范围
	if current_scale is float:
		current_scale = clamp(current_scale, min_scale, max_scale)
	
	scale_changed.emit(current_scale)

## 更新安全区域
func _update_safe_area() -> void:
	var viewport = UIManager.get_viewport()
	if viewport:
		var screen_size = viewport.get_visible_rect().size
		var content_scale_size = screen_size
		
		if maintain_aspect_ratio:
			var aspect = reference_resolution.x / reference_resolution.y
			var current_aspect = screen_size.x / screen_size.y
			
			if current_aspect > aspect:
				content_scale_size.x = screen_size.y * aspect
			else:
				content_scale_size.y = screen_size.x / aspect
		
		var offset = (screen_size - content_scale_size) / 2
		safe_area = Rect2(offset, content_scale_size)
		safe_area_changed.emit(safe_area)

## 窗口大小改变回调
func _on_viewport_size_changed() -> void:
	actual_resolution = UIManager.get_viewport().get_visible_rect().size
	resolution_changed.emit(actual_resolution)
	_update_safe_area()
	_update_ui_scale()

## 获取基于参考分辨率的实际尺寸
func get_adapted_size(original_size: Vector2) -> Vector2:
	if current_scale is float:
		return original_size * current_scale
	else:
		return Vector2(
			original_size.x * current_scale,
			original_size.y * current_scale
		)

## 获取基于参考分辨率的实际位置
func get_adapted_position(original_position: Vector2) -> Vector2:
	var adapted_pos = original_position
	if maintain_aspect_ratio:
		adapted_pos = adapted_pos + safe_area.position
	return adapted_pos * current_scale
