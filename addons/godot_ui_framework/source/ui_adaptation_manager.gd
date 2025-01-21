extends Node
class_name UIAdaptationManager

## 屏幕适配

## 参考分辨率
@export var reference_resolution: Vector2 = Vector2(1920, 1080)

## 当前安全区域
signal safe_area_changed(new_area: Rect2)