extends BaseStateMachine
class_name EnemyStateMachine

## Enemy状态机

var enemy: FieldEnemy

func _init(p_enemy: FieldEnemy) -> void:
	enemy = p_enemy
	
	# 注册状态
	states[&"idle"] = EnemyIdleState.new(self)
	states[&"patrol"] = EnemyPatrolState.new(self)
	states[&"chase"] = EnemyChaseState.new(self)
	states[&"battle"] = EnemyBattleState.new(self)
	
	# 设置初始状态
	current_state = states[&"idle"]
