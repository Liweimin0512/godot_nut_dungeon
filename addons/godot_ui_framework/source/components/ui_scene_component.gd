extends UIViewComponent
class_name UISceneComponent

## UI场景组件，代表一个UI场景
## 负责管理UI场景的生命周期

## 分组ID
@export var group_id: StringName = ""
## 是否隐藏同组其他界面
@export var hide_others: bool = true
## 是否模态
@export var is_modal: bool = false
## 是否阻挡输入
@export var block_input: bool = true

## 场景打开
signal scene_opened(scene: Control)
## 场景关闭
signal scene_closed(scene: Control)

func _ready() -> void:
	if is_modal:
		_setup_modal_blocker()

## 重写初始化方法
func initialize(data: Dictionary = {}) -> void:
	await super(data)
	scene_opened.emit(owner)

## 重写销毁方法
func dispose() -> void:
	await super()
	scene_closed.emit(owner)

## 设置模态遮罩
func _setup_modal_blocker() -> void:
	var blocker = ColorRect.new()
	blocker.name = "ModalBlocker"
	blocker.color = Color(0, 0, 0, 0.5)
	blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP if block_input else Control.MOUSE_FILTER_IGNORE
	
	owner.add_child(blocker)
	blocker.move_to_front()
	owner.move_to_front()

## 获取分组ID
func get_group_id() -> StringName:
	return group_id

## 设置是否阻挡输入
func set_block_input(value: bool) -> void:
	block_input = value
	var blocker = owner.get_node_or_null("ModalBlocker")
	if blocker:
		blocker.mouse_filter = Control.MOUSE_FILTER_STOP if value else Control.MOUSE_FILTER_IGNORE
