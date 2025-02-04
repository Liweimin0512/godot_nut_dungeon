extends CharacterBody2D
class_name FieldPlayer

## 移动速度
@export var move_speed := 200.0
## 冲刺速度倍率
@export var sprint_multiplier := 1.5
## 动画播放器
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
## 精灵节点
@onready var _sprite: Sprite2D = $Sprite2D

## 当前面朝方向
var _facing_direction := Vector2.DOWN
## 当前动作状态
var _current_action := "idle"
## 当前朝向状态
var _current_direction := "down"
## 是否正在攻击
var _is_attacking := false

func _ready() -> void:
	# 开始播放待机动画
	_play_animation("idle", "down")

func _physics_process(_delta: float) -> void:
	if _is_attacking:
		return
		
	var input_direction := Vector2.ZERO
	input_direction.x = Input.get_axis("ui_left", "ui_right")
	input_direction.y = Input.get_axis("ui_up", "ui_down")
	input_direction = input_direction.normalized()
	
	# 处理移动
	if input_direction != Vector2.ZERO:
		_facing_direction = input_direction
		
		# 更新朝向
		_update_direction(input_direction)
		
		# 检查是否冲刺（按住Shift键）
		var is_sprinting := Input.is_action_pressed("ui_sprint")
		var current_speed := move_speed * (sprint_multiplier if is_sprinting else 1.0)
		
		velocity = input_direction * current_speed
		_play_animation("walk", _current_direction)
	else:
		velocity = Vector2.ZERO
		_play_animation("idle", _current_direction)
	
	# 检测攻击输入
	if Input.is_action_just_pressed("ui_accept"):  # 空格键攻击
		attack()
	
	move_and_slide()

## 更新朝向
func _update_direction(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		# 水平移动
		_current_direction = "side"
		_sprite.flip_h = direction.x < 0
	else:
		# 垂直移动
		_current_direction = "down" if direction.y > 0 else "up"
		_sprite.flip_h = false

## 播放动画
func _play_animation(action: String, direction: String) -> void:
	var anim_name := action + "_" + direction
	if _animation_player.has_animation(anim_name) and _animation_player.current_animation != anim_name:
		_animation_player.play(anim_name)

## 执行攻击动作
func attack() -> void:
	if _is_attacking:
		return
		
	_is_attacking = true
	_play_animation("attack", _current_direction)
	
	# 等待攻击动画完成
	await _animation_player.animation_finished
	
	_is_attacking = false
	_play_animation("idle", _current_direction)

## 执行死亡动作
func die() -> void:
	_is_attacking = true  # 禁用其他动作
	_animation_player.play("death")
	# 禁用输入
	set_physics_process(false)

## 与NPC或物体交互
func interact() -> void:
	if _is_attacking:
		return
		
	# 获取交互射线的终点
	var interaction_point := global_position + _facing_direction * 32.0
	
	# 检测可交互物体
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, interaction_point)
	var result := space_state.intersect_ray(query)
	
	if result:
		if result.collider.has_method("on_interact"):
			result.collider.on_interact(self)
