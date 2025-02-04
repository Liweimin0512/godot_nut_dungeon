extends PanelContainer
class_name ItemSlotUI

## 物品槽UI组件
## 负责管理物品槽的状态和与背包系统的交互

# 信号
## 物品点击信号
signal item_clicked(slot: int, button: int)
## 物品双击信号
signal item_double_clicked(slot: int)
## 物品拖拽开始信号
signal item_drag_started(slot: int)
## 物品拖拽结束信号
signal item_dropped(from_slot: int, to_slot: int)
## 物品槽状态变化信号
signal state_changed()

# 导出变量
## 槽位索引
@export var slot_index: int = 0
## 物品实例
@export var item_instance: ItemInstance:
	set(value):
		item_instance = value
		if _item_tile:
			_item_tile.item_instance = value
## 是否可用
@export var enabled: bool = true:
	set(value):
		enabled = value
		_update_state()
## 是否可放入物品
@export var droppable: bool = true
## 是否可取出物品
@export var draggable: bool = true
## 物品类型限制
@export var allowed_types: Array[int]
## 物品ID限制
@export var allowed_ids: Array[String]

# 节点引用
@onready var _item_tile: ItemTile = %ItemTile
@onready var _highlight: ColorRect = %Highlight
@onready var _disabled_overlay: ColorRect = %DisabledOverlay

func _ready() -> void:
	# 连接ItemTile信号
	_item_tile.clicked.connect(_on_item_tile_clicked)
	_item_tile.double_clicked.connect(_on_item_tile_double_clicked)
	_item_tile.drag_started.connect(_on_item_tile_drag_started)
	_item_tile.drag_ended.connect(_on_item_tile_drag_ended)
	_item_tile.mouse_entered.connect(_on_item_tile_mouse_entered)
	_item_tile.mouse_exited.connect(_on_item_tile_mouse_exited)
	
	# 设置初始状态
	_item_tile.item_instance = item_instance
	_item_tile.draggable = draggable
	_update_state()

## 更新状态
func _update_state() -> void:
	if not is_node_ready():
		return
		
	if enabled:
		_disabled_overlay.hide()
		modulate = Color.WHITE
	else:
		_disabled_overlay.show()
		modulate = Color(0.7, 0.7, 0.7, 1.0)
	
	state_changed.emit()

## 判断是否可以放入指定物品
func can_accept_item(item: ItemInstance) -> bool:
	if not enabled or not droppable or not item:
		return false
	
	# 检查类型限制
	if not allowed_types.is_empty() and not (item.item_data.type in allowed_types):
		return false
	
	# 检查ID限制
	if not allowed_ids.is_empty() and not (item.item_data.id in allowed_ids):
		return false
	
	return true

## 高亮显示
func highlight(show: bool = true) -> void:
	_highlight.visible = show

# 信号处理
func _on_item_tile_clicked(button_index: int) -> void:
	if enabled:
		item_clicked.emit(slot_index, button_index)

func _on_item_tile_double_clicked() -> void:
	if enabled:
		item_double_clicked.emit(slot_index)

func _on_item_tile_drag_started() -> void:
	if enabled and draggable:
		item_drag_started.emit(slot_index)

func _on_item_tile_drag_ended() -> void:
	if enabled:
		item_dropped.emit(slot_index, -1)  # -1表示没有目标槽位

func _on_item_tile_mouse_entered() -> void:
	if enabled and droppable:
		highlight(true)

func _on_item_tile_mouse_exited() -> void:
	highlight(false)
