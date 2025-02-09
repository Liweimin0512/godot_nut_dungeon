extends BaseState
class_name EnemyIdleState

## Enemy待机状态

var state_machine: EnemyStateMachine

func _init(p_state_machine: EnemyStateMachine) -> void:
	state_machine = p_state_machine

func enter(msg: Dictionary = {}) -> bool:
	if not super(msg):
		return false
	
	state_machine.enemy._animation_player.play("idle_down")
	state_machine.enemy.velocity = Vector2.ZERO
	state_machine.enemy._state_timer.start(randf_range(2.0, 4.0))
	return true

func update(delta: float) -> void:
	super(delta)
	
	if state_machine.enemy._state_timer.is_stopped():
		# 随机选择巡逻点
		var random_offset = Vector2(
			randf_range(-state_machine.enemy.patrol_range, state_machine.enemy.patrol_range),
			randf_range(-state_machine.enemy.patrol_range, state_machine.enemy.patrol_range)
		)
		state_machine.values["target_position"] = state_machine.enemy._initial_position + random_offset
		state_machine.enemy._navigation_agent.target_position = state_machine.values["target_position"]
		state_machine.change_state(&"patrol")
