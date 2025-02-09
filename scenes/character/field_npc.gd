extends CharacterBody2D
class_name FieldNPC

## 交互范围
@export var interaction_range := 50.0
## 交互UI节点
@onready var _interaction_ui: Node2D = $InteractionUI
## 精灵节点
@onready var _sprite: Sprite2D = $Sprite2D
## 交互区域
@onready var _interaction_area: Area2D = $InteractionArea
## 对话内容
@export var dialogue_content: Array[String] = ["你好！"]

signal interaction_started(npc: FieldNPC)

func _ready() -> void:
	# 初始化时隐藏交互UI
	_interaction_ui.hide()
	# 设置交互区域大小
	var collision_shape = _interaction_area.get_node("CollisionShape2D")
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = interaction_range
	collision_shape.shape = circle_shape

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body is FieldPlayer:
		_interaction_ui.show()

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body is FieldPlayer:
		_interaction_ui.hide()

## 当玩家按下交互键时调用
func interact() -> void:
	interaction_started.emit(self)

## 获取对话内容
func get_dialogue() -> Array[String]:
	return dialogue_content
