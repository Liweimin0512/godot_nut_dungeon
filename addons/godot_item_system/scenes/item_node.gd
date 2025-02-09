extends Node2D
class_name ItemNode

## 场景中的物品节点
## 用于在游戏场景中显示和交互的物品

# 信号
signal item_picked_up(item: ItemInstance)
signal item_interacted(item: ItemNode)

# 导出变量
@export var item_instance: ItemInstance:
	set(value):
		item_instance = value
		_update_display()

@export var auto_pickup: bool = true
@export var interaction_range: float = 32.0
@export var floating: bool = true
@export var floating_height: float = 5.0
@export var floating_speed: float = 2.0

# 节点引用
@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var collision_shape: CollisionShape2D = $InteractionArea/CollisionShape2D
@onready var label: Label = $Label

# 内部变量
var _initial_position: Vector2
var _time: float = 0.0

func _ready() -> void:
	_initial_position = position
	
	# 设置交互区域
	var shape = CircleShape2D.new()
	shape.radius = interaction_range
	collision_shape.shape = shape
	
	# 连接信号
	interaction_area.body_entered.connect(_on_body_entered)
	
	# 更新显示
	_update_display()

func _process(delta: float) -> void:
	if floating:
		_time += delta * floating_speed
		position.y = _initial_position.y + sin(_time) * floating_height

func _update_display() -> void:
	if not is_node_ready() or not item_instance:
		return
		
	# 更新贴图
	sprite.texture = item_instance.item_data.icon
	
	# 更新标签
	if item_instance.quantity > 1:
		label.text = str(item_instance.quantity)
		label.show()
	else:
		label.hide()

func _on_body_entered(body: Node2D) -> void:
	if not item_instance:
		return
		
	if body.has_method("can_pickup_item") and not body.can_pickup_item(item_instance):
		return
		
	if auto_pickup:
		pickup(body)
	else:
		item_interacted.emit(self)

## 拾取物品
func pickup(picker: Node) -> void:
	if not item_instance:
		return
		
	item_picked_up.emit(item_instance)
	queue_free()

## 显示物品名称
func show_name() -> void:
	if not item_instance:
		return
		
	label.text = item_instance.item_data.get_localized_name()
	label.show()

## 隐藏物品名称
func hide_name() -> void:
	label.hide()
