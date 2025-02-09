extends BaseState
class_name EnemyBattleState

## Enemy战斗状态

var state_machine: EnemyStateMachine

func _init(p_state_machine: EnemyStateMachine) -> void:
	state_machine = p_state_machine

func enter(msg: Dictionary = {}) -> bool:
	if not super(msg):
		return false
	
	state_machine.enemy._animation_player.play("attack_down")
	state_machine.enemy.velocity = Vector2.ZERO
	state_machine.enemy.battle_started.emit(state_machine.enemy)
	return true
