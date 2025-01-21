# ui_widget_component.gd
extends UIViewComponent
class_name UIWidgetComponent

## 是否可重用
@export var reusable: bool = true
## 是否自动回收
@export var auto_recycle: bool = true

## 控件准备好
signal widget_ready(widget: Control)
## 控件被回收
signal widget_recycled(widget: Control)

## 回收控件
func recycle() -> void:
	if not reusable:
		dispose()
		return
	
	if owner.has_method("_on_recycle"):
		owner.call("_on_recycle")
	
	widget_recycled.emit(owner)
