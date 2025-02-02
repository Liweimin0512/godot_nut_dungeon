extends WidgetComponent
class_name ItemSlotUI

## 物品槽UI组件
## 负责显示单个物品槽的内容和交互

# 信号
signal item_clicked(slot: int, button: int)
signal item_double_clicked(slot: int)
signal item_drag_started(slot: int)
signal item_dropped(from_slot: int, to_slot: int)

# 导出变量
@export var slot_index: int = 0
@export var item_instance: ItemInstance:
	set(value):
		item_instance = value
		_update_display()

# 节点引用
@onready var icon = $Icon
@onready var quantity_label = $QuantityLabel
@onready var rarity_frame = $RarityFrame
@onready var enhancement_label = $EnhancementLabel

# 内部变量
var _dragging: bool = false
var _drag_preview: TextureRect

func _ready() -> void:
	super._ready()
	_update_display()
	
	# 连接信号
	gui_input.connect(_on_gui_input)

## 更新显示
func _update_display() -> void:
	if not is_node_ready():
		return
		
	if item_instance:
		icon.texture = item_instance.item_data.icon
		icon.show()
		
		if item_instance.quantity > 1:
			quantity_label.text = str(item_instance.quantity)
			quantity_label.show()
		else:
			quantity_label.hide()
			
		if item_instance.enhancement_level > 0:
			enhancement_label.text = "+" + str(item_instance.enhancement_level)
			enhancement_label.show()
		else:
			enhancement_label.hide()
			
		rarity_frame.modulate = item_instance.item_data.get_rarity_color()
		rarity_frame.show()
	else:
		icon.hide()
		quantity_label.hide()
		enhancement_label.hide()
		rarity_frame.hide()

## 处理输入事件
func _on_gui_input(event: InputEvent) -> void:
	if not item_instance:
		return
		
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					if event.double_click:
						item_double_clicked.emit(slot_index)
					else:
						item_clicked.emit(slot_index, event.button_index)
						_start_drag()
				MOUSE_BUTTON_RIGHT:
					item_clicked.emit(slot_index, event.button_index)
		else:
			if event.button_index == MOUSE_BUTTON_LEFT:
				_end_drag()

## 开始拖动
func _start_drag() -> void:
	if _dragging or not item_instance:
		return
		
	_dragging = true
	item_drag_started.emit(slot_index)
	
	# 创建拖动预览
	_drag_preview = TextureRect.new()
	_drag_preview.texture = item_instance.item_data.icon
	_drag_preview.modulate.a = 0.5
	add_child(_drag_preview)
	_drag_preview.global_position = get_global_mouse_position() - _drag_preview.size / 2

## 结束拖动
func _end_drag() -> void:
	if not _dragging:
		return
		
	_dragging = false
	if _drag_preview:
		_drag_preview.queue_free()
		_drag_preview = null
	
	# 检查是否放在其他物品槽上
	var target_slot = _find_target_slot()
	if target_slot != -1 and target_slot != slot_index:
		item_dropped.emit(slot_index, target_slot)

## 查找目标槽位
func _find_target_slot() -> int:
	var mouse_pos = get_global_mouse_position()
	var parent = get_parent()
	
	if not parent:
		return -1
		
	for child in parent.get_children():
		if child is ItemSlotUI and child != self:
			if child.get_global_rect().has_point(mouse_pos):
				return child.slot_index
	
	return -1

## 处理拖动
func _process(_delta: float) -> void:
	if _dragging and _drag_preview:
		_drag_preview.global_position = get_global_mouse_position() - _drag_preview.size / 2
