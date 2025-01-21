extends UIWidgetType
class_name UIFormType

## UI控件数据模型，根据这个模型实例化控件对应的UI场景

## 分组
@export var groupID : StringName = ""
## 隐藏同组其他界面
@export var hide_others : bool = true
## 过渡动画
@export var transition: UITransition
## 层级
@export var layer: int = 0
## 是否是模态窗口
@export var is_modal: bool = false  

func _init(
		p_ID: StringName = "", 
		p_scene:PackedScene = null, 
		p_groupID: StringName = "", 
		p_hide_others: bool = true,
		p_preload_mode: PRELOAD_MODE = PRELOAD_MODE.ON_DEMAND,
		p_cache_mode: CACHE_MODE = CACHE_MODE.DESTROY_ON_CLOSE,
		p_transition: UITransition = null,
		p_layer: int = 0,
		p_is_modal: bool = false
		) -> void:
	ID = p_ID
	scene = p_scene
	groupID = p_groupID
	hide_others = p_hide_others
	preload_mode = p_preload_mode
	cache_mode = p_cache_mode
	transition = p_transition
	layer = p_layer
	is_modal = p_is_modal
