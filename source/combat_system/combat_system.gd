extends Node

## 战斗管理器单例

## 当前存在的战斗
var _current_combats: Array[Combat]

## 创建战斗
func create_combat(
		players: Array[CombatComponent], 
		enemies : Array[CombatComponent],
		max_turn_count: int = 99,
		is_auto := true,
		is_real_time := true
	) -> Combat:
	var combat : Combat = Combat.new(
		players,
		enemies,
		max_turn_count,
		is_auto,
		is_real_time
	)
	combat.combat_ended.connect(
		func() -> void:
			_current_combats.erase(combat)
	)
	_current_combats.append(combat)
	return combat