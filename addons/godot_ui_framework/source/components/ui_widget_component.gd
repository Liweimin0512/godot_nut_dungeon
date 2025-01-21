# widget_base.gd
extends Node
class_name UIWidgetComponent

## 控件基类组件，表示其父节点是一个控件

# 控件数据模型
var model: Dictionary = {}

## 控件准备好
signal widget_ready
## 控件被销毁
signal widget_disposed

## 初始化控件
func initialize(data: Dictionary = {}) -> void:
	model = data
	if owner.has_method("_setup"):
		owner.call("_setup", model)
	widget_ready.emit()

## 更新控件数据
func update_data(data: Dictionary) -> void:
	model.merge(data, true)
	if owner.has_method("_refresh"):
		owner.call("_refresh", model)

## 销毁控件
func dispose() -> void:
	if owner.has_method("_cleanup"):
		owner.has_method("_cleanup")
	widget_disposed.emit()
