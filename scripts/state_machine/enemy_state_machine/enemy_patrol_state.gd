extends BaseState
class_name EnemyPatrolState

## Enemy巡逻状态

var state_machine: EnemyStateMachine

func _init(p_state_machine: EnemyStateMachine) -> void:
	state_machine = p_state_machine

func enter(msg: Dictionary = {}) -> bool:
	if not super(msg):
		return false
	
	state_machine.enemy._animation_player.play("walk_down")
	return true

func physics_update(delta: float) -> void:
	super(delta)
	
	if state_machine.enemy._navigation_agent.is_navigation_finished():
		state_machine.change_state(&"idle")
		return
	
	var next_position = state_machine.enemy._navigation_agent.get_next_path_position()
	var direction = state_machine.enemy.global_position.direction_to(next_position)
	state_machine.enemy.velocity = direction * state_machine.enemy.move_speed
	
	# 更新动画方向
	var angle = direction.angle()
	if abs(angle) < PI/4:
		state_machine.enemy._animation_player.play("walk_side")
		state_machine.enemy._sprite.flip_h = false
	elif abs(angle) > 3*PI/4:
		state_machine.enemy._animation_player.play("walk_side")
		state_machine.enemy._sprite.flip_h = true
	elif angle > 0:
		state_machine.enemy._animation_player.play("walk_down")
	else:
		state_machine.enemy._animation_player.play("walk_up")
