extends Resource
class_name UITransition

## UI过渡动画

## 过渡动画类型
enum TRANSITION_TYPE{
    FADE,   ## 透明度过渡
    SLIDE,   ## 滑动过渡
    SCALE,   ## 缩放过渡
    ROTATE,  ## 旋转过渡
    CUSTOM,  ## 自定义过渡
}

@export var duration: float = 0.3
@export var transition_type: TRANSITION_TYPE
@export var ease_type: Tween.EaseType

func apply_transition(ui: Control, is_opening: bool) -> void:
    # 实现过渡动画逻辑
    pass