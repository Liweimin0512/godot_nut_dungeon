# source/module/transition/ui_transition_manager.gd
extends RefCounted
class_name UITransitionManager

## 默认过渡配置
var default_transition: UITransition = UITransition.new()

## 过渡配置缓存
var _transition_cache: Dictionary = {}

## 初始化
func _init() -> void:
	default_transition = UITransition.new()
	default_transition.transition_type = UITransition.TRANSITION_TYPE.FADE
	default_transition.duration = 0.3

## 注册过渡配置
func register_transition(name: String, transition: UITransition) -> void:
	_transition_cache[name] = transition

## 获取过渡配置
func get_transition(name: String = "") -> UITransition:
	return _transition_cache.get(name, default_transition)

## 应用打开过渡
func apply_open_transition(ui: Control, transition_name: String = "") -> void:
	var transition = get_transition(transition_name)
	transition.apply_open_transition(ui)

## 应用关闭过渡
func apply_close_transition(ui: Control, transition_name: String = "") -> void:
	var transition = get_transition(transition_name)
	transition.apply_close_transition(ui)
