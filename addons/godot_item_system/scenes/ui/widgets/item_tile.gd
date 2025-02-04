extends Control
class_name ItemTile

## 物品显示组件
## 负责显示单个物品的图标、数量等信息，处理拖放操作

# 信号
signal clicked(button_index: int)           ## 点击信号
signal double_clicked()                     ## 双击信号
signal drag_started()                       ## 开始拖动
signal drag_ended()                         ## 结束拖动

# 导出变量
@export var item_instance: ItemInstance:    ## 物品实例
	set(value):
		item_instance = value
		_update_display()

@export var draggable: bool = true         ## 是否可拖动
@export var show_rarity: bool = true       ## 是否显示稀有度
@export var show_quantity: bool = true     ## 是否显示数量
@export var show_enhancement: bool = true   ## 是否显示强化等级

# 节点引用
@onready var icon: TextureRect = %Icon
@onready var quantity_label: Label = %QuantityLabel
@onready var rarity_frame: ColorRect = %RarityFrame
@onready var enhancement_label: Label = %EnhancementLabel

# 内部变量
var _dragging: bool = false
var _drag_preview: Control
var _initial_mouse_pos: Vector2
var _drag_threshold: float = 5.0

func _ready() -> void:
	# 连接信号
	gui_input.connect(_on_gui_input)
	
	# 初始化显示
	_update_display()

func _update_display() -> void:
	if not is_node_ready():
		return
		
	if item_instance:
		# 显示图标
		icon.texture = item_instance.item_data.icon
		icon.show()
		
		# 显示数量
		if show_quantity and item_instance.quantity > 1:
			quantity_label.text = str(item_instance.quantity)
			quantity_label.show()
		else:
			quantity_label.hide()
			
		# 显示强化等级
		if show_enhancement and item_instance.enhancement_level > 0:
			enhancement_label.text = "+" + str(item_instance.enhancement_level)
			enhancement_label.show()
		else:
			enhancement_label.hide()
			
		# 显示稀有度边框
		if show_rarity:
			rarity_frame.modulate = item_instance.item_data.get_rarity_color()
			rarity_frame.show()
		else:
			rarity_frame.hide()
	else:
		# 隐藏所有显示
		icon.hide()
		quantity_label.hide()
		enhancement_label.hide()
		rarity_frame.hide()

func _on_gui_input(event: InputEvent) -> void:
	if not item_instance:
		return
		
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					if event.double_click:
						double_clicked.emit()
					else:
						clicked.emit(event.button_index)
						if draggable:
							_start_drag(event.position)
				MOUSE_BUTTON_RIGHT:
					clicked.emit(event.button_index)
		else:
			if event.button_index == MOUSE_BUTTON_LEFT and _dragging:
				_end_drag()
	
	elif event is InputEventMouseMotion:
		if _dragging:
			_update_drag_preview()
		elif draggable and event.button_mask == MOUSE_BUTTON_LEFT:
			var delta = event.position - _initial_mouse_pos
			if delta.length() > _drag_threshold:
				_start_drag(event.position)

func _start_drag(pos: Vector2) -> void:
	if _dragging:
		return
		
	_dragging = true
	_initial_mouse_pos = pos
	
	# 创建拖动预览
	_drag_preview = Control.new()
	_drag_preview.custom_minimum_size = size
	_drag_preview.size = size
	_drag_preview.modulate.a = 0.5
	
	var preview_icon = TextureRect.new()
	preview_icon.texture = item_instance.item_data.icon
	#preview_icon.expand_mode = TextureRect.EXPAND_FILL
	preview_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_icon.size = size
	_drag_preview.add_child(preview_icon)
	
	add_child(_drag_preview)
	_drag_preview.global_position = get_global_mouse_position() - size / 2
	
	drag_started.emit()

func _end_drag() -> void:
	if not _dragging:
		return
		
	_dragging = false
	if _drag_preview:
		_drag_preview.queue_free()
		_drag_preview = null
	
	drag_ended.emit()

func _update_drag_preview() -> void:
	if _dragging and _drag_preview:
		_drag_preview.global_position = get_global_mouse_position() - size / 2

## 获取拖动状态
func is_dragging() -> bool:
	return _dragging

## 取消拖动
func cancel_drag() -> void:
	if _dragging:
		_end_drag()
