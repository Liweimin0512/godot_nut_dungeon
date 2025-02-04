extends CharacterBody2D
class_name FieldEnemy

## 移动速度
@export var move_speed := 100.0
## 追击速度
@export var chase_speed := 150.0
## 巡逻范围
@export var patrol_range := 100.0
## 视野范围
@export var vision_range := 150.0
## 触发战斗范围
@export var battle_range := 20.0

## 精灵节点
@onready var _sprite: Sprite2D = $Sprite2D
## 视野区域
@onready var _vision_area: Area2D = $VisionArea
## 战斗触发区域
@onready var _battle_area: Area2D = $BattleArea
## 导航代理
@onready var _navigation_agent: NavigationAgent2D = $NavigationAgent2D
## 状态机计时器
@onready var _state_timer: Timer = $StateTimer
## 动画播放器
@onready var _animation_player: AnimationPlayer = $AnimationPlayer

## 初始位置
var _initial_position: Vector2
## 玩家引用
var _player: FieldPlayer = null

signal battle_started(enemy: FieldEnemy)

func _ready() -> void:
	_initial_position = global_position
	
	# 设置视野区域
	var vision_shape = CircleShape2D.new()
	vision_shape.radius = vision_range
	_vision_area.get_node("CollisionShape2D").shape = vision_shape
	
	# 设置战斗触发区域
	var battle_shape = CircleShape2D.new()
	battle_shape.radius = battle_range
	_battle_area.get_node("CollisionShape2D").shape = battle_shape
	
	# 注册状态机
	var state_machine = EnemyStateMachine.new(self)
	StateMachineManager.register_state_machine(&"enemy_%s" % get_instance_id(), state_machine, &"idle")

func _physics_process(delta: float) -> void:
	move_and_slide()

func _on_vision_area_body_entered(body: Node2D) -> void:
	if body is FieldPlayer:
		_player = body
		StateMachineManager.change_state(&"enemy_%s" % get_instance_id(), &"chase")

func _on_vision_area_body_exited(body: Node2D) -> void:
	if body is FieldPlayer:
		_player = null

func _on_battle_area_body_entered(body: Node2D) -> void:
	if body is FieldPlayer:
		StateMachineManager.change_state(&"enemy_%s" % get_instance_id(), &"battle")
