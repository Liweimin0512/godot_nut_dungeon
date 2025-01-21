extends Node
class_name UIAdaptationComponent

## 适配模式
@export var adaptation_mode: UIAdaptationManager.ScaleMode = UIAdaptationManager.ScaleMode.FIT
## 是否使用安全区域
@export var use_safe_area: bool = false
## 是否自动适配
@export var auto_adapt: bool = true

var _owner_control: Control

func _ready() -> void:
    _owner_control = get_parent() as Control
    if not _owner_control:
        push_error("UIAdaptationComponent must be child of a Control node")
        return
    
    if UIManager.is_module_enabled("adaptation"):
        var adaptation_manager = UIManager.adaptation_manager
        if adaptation_manager:
            adaptation_manager.scale_changed.connect(_on_scale_changed)
            adaptation_manager.safe_area_changed.connect(_on_safe_area_changed)
            
            if auto_adapt:
                adapt()

## 适配
func adapt() -> void:
    if not _owner_control or not UIManager.is_module_enabled("adaptation"):
        return
        
    var adaptation_manager = UIManager.adaptation_manager
    if not adaptation_manager:
        return
    
    # 应用缩放
    var scale = adaptation_manager.current_scale
    _owner_control.scale = Vector2(scale, scale)
    
    # 应用安全区域
    if use_safe_area:
        var safe_area = adaptation_manager.safe_area
        _owner_control.position = safe_area.position
        _owner_control.size = safe_area.size

## 缩放改变回调
func _on_scale_changed(new_scale: float) -> void:
    if auto_adapt:
        adapt()

## 安全区域改变回调
func _on_safe_area_changed(new_safe_area: Rect2) -> void:
    if auto_adapt and use_safe_area:
        adapt()