# virtual_joystick.gd
extends Control

## 虚拟摇杆组件
## 用于移动设备的方向输入控制

## 摇杆类型
enum JoystickType {
    FIXED,      # 固定位置
    DYNAMIC     # 动态位置（触摸位置）
}

## 摇杆移动信号
signal joystick_moved(direction: Vector2)
## 摇杆释放信号
signal joystick_released

## 配置参数
@export var joystick_type: JoystickType = JoystickType.DYNAMIC
@export var dead_zone: float = 0.2        # 死区
@export var clamp_zone: float = 1.0       # 限制区域
@export var return_speed: float = 10.0    # 回弹速度
@export var visibility_mode: bool = true   # true: 始终显示, false: 仅使用时显示

## 内部节点
@onready var _base: TextureRect = $Base
@onready var _tip: TextureRect = $Base/Tip

## 状态变量
var _touch_index: int = -1           # 触摸索引
var _base_radius: float              # 基座半径
var _tip_radius: float               # 摇杆半径
var _base_default_pos: Vector2       # 基座默认位置
var _tip_default_pos: Vector2        # 摇杆默认位置
var _current_direction: Vector2      # 当前方向
var _is_active: bool = false         # 是否激活

func _ready() -> void:
    # 初始化大小
    _base_radius = _base.size.x / 2
    _tip_radius = _tip.size.x / 2
    
    # 记录默认位置
    _base_default_pos = _base.position
    _tip_default_pos = _tip.position
    
    # 设置初始可见性
    if not visibility_mode:
        _base.modulate.a = 0
    
    # 确保Control节点可以接收输入
    mouse_filter = Control.MOUSE_FILTER_STOP

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        _handle_touch(event)
    elif event is InputEventScreenDrag:
        _handle_drag(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
    if event.pressed:
        # 检查是否已经有激活的触摸
        if _touch_index != -1:
            return
            
        # 检查触摸位置是否在控制区域内
        var touch_pos = event.position
        if joystick_type == JoystickType.FIXED:
            # 固定模式：检查是否在基座范围内
            if _is_within_base(touch_pos):
                _activate_joystick(event.index, touch_pos)
        else:
            # 动态模式：在触摸位置创建摇杆
            if get_rect().has_point(touch_pos):
                _activate_joystick(event.index, touch_pos)
    else:
        # 释放触摸
        if event.index == _touch_index:
            _deactivate_joystick()

func _handle_drag(event: InputEventScreenDrag) -> void:
    if event.index == _touch_index:
        var delta = event.position - _base.global_position
        var direction = delta.normalized()
        var distance = delta.length()
        
        # 应用死区
        if distance < _base_radius * dead_zone:
            _current_direction = Vector2.ZERO
            _tip.position = _tip_default_pos
        else:
            # 计算摇杆位置和方向
            distance = min(distance, _base_radius * clamp_zone)
            _current_direction = direction
            _tip.position = _tip_default_pos + direction * distance
            
        # 发送方向信号
        joystick_moved.emit(_current_direction)

func _activate_joystick(index: int, pos: Vector2) -> void:
    _touch_index = index
    _is_active = true
    
    if joystick_type == JoystickType.DYNAMIC:
        _base.global_position = pos - _base.size / 2
    
    if not visibility_mode:
        # 显示摇杆
        var tween = create_tween()
        tween.tween_property(_base, "modulate:a", 1.0, 0.2)

func _deactivate_joystick() -> void:
    _touch_index = -1
    _is_active = false
    _current_direction = Vector2.ZERO
    
    # 重置摇杆位置
    if joystick_type == JoystickType.DYNAMIC:
        _base.position = _base_default_pos
    _tip.position = _tip_default_pos
    
    if not visibility_mode:
        # 隐藏摇杆
        var tween = create_tween()
        tween.tween_property(_base, "modulate:a", 0.0, 0.2)
    
    # 发送释放信号
    joystick_released.emit()

func _is_within_base(global_pos: Vector2) -> bool:
    var delta = global_pos - _base.global_position - _base.size / 2
    return delta.length_squared() <= pow(_base_radius, 2)

## 获取当前方向
func get_direction() -> Vector2:
    return _current_direction

## 是否正在使用
func is_active() -> bool:
    return _is_active

## 设置可见性模式
func set_visibility_mode(always_visible: bool) -> void:
    visibility_mode = always_visible
    if always_visible and not _is_active:
        _base.modulate.a = 1.0