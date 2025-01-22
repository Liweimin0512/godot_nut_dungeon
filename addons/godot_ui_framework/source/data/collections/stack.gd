# stack.gd
extends RefCounted
class_name Stack

## 内部存储数组
var _items: Array = []

## 获取栈大小
var size: int:
	get:
		return _items.size()

## 判断栈是否为空
var is_empty: bool:
	get:
		return _items.is_empty()

## 获取栈顶元素但不移除
func peek():
	if is_empty:
		push_error("Stack is empty")
		return null
	return _items[-1]

## 压入元素到栈顶
func push(item) -> void:
	_items.push_back(item)

## 弹出栈顶元素
func pop():
	if is_empty:
		push_error("Stack is empty")
		return null
	return _items.pop_back()

## 清空栈
func clear() -> void:
	_items.clear()

## 转换为数组
func to_array() -> Array:
	return _items.duplicate()

## 打印栈内容（用于调试）
func _to_string() -> String:
	return "Stack(size: %d, items: %s)" % [size, str(_items)]
