extends Node
class_name UIViewComponent

## UI视图基础组件
## 所有UI组件的基类，提供基本的生命周期和数据管理

## 视图数据模型
var model: Dictionary = {}

## 视图准备好
signal view_ready(view: Control)
## 视图被销毁
signal view_disposed(view: Control)
## 过渡动画开始
signal transition_started(view: Control)
## 过渡动画结束
signal transition_completed(view: Control)

## 层级
@export var layer: int = 0
## 过渡动画
@export var transition: UITransition

## 当前状态
var _is_initialized: bool = false

## 初始化视图
func initialize(data: Dictionary = {}) -> void:
    if _is_initialized:
        return
        
    model = data
    if owner.has_method("_setup"):
        owner.call("_setup", model)
    
    # 播放过渡动画
    if transition:
        transition_started.emit(owner)
        await transition.play_enter(owner)
        transition_completed.emit(owner)
    
    _is_initialized = true
    view_ready.emit(owner)

## 更新视图数据
func update_data(data: Dictionary) -> void:
    model.merge(data, true)
    if owner.has_method("_refresh"):
        owner.call("_refresh", model)

## 销毁视图
func dispose() -> void:
    if not _is_initialized:
        return
    
    # 播放退出动画
    if transition:
        transition_started.emit(owner)
        await transition.play_exit(owner)
        transition_completed.emit(owner)
    
    if owner.has_method("_cleanup"):
        owner.call("_cleanup")
    
    _is_initialized = false
    view_disposed.emit(owner)

## 获取视图数据
func get_data() -> Dictionary:
    return model

## 获取层级
func get_layer() -> int:
    return layer

## 设置层级
func set_layer(value: int) -> void:
    layer = value

## 获取过渡动画
func get_transition() -> UITransition:
    return transition

## 设置过渡动画
func set_transition(value: UITransition) -> void:
    transition = value

## 是否已初始化
func is_initialized() -> bool:
    return _is_initialized