extends Node

@export var max_turn_count: int = 99
var _turn_count : int = 0
var combats : Array[CombatComponent]:
	get:
		var cs: Array[CombatComponent]
		for cha : Character in get_tree().get_nodes_in_group("Character"):
			cs.append(cha.combat_component)
		return cs

signal combat_started
signal turn_started
signal turn_ended
signal combat_finished
signal combat_defeated

func combat_start() -> void:
	_combat_start()

## 战斗开始
func _combat_start() -> void:
	print("战斗开始！")
	combat_started.emit()
	for combat in combats:
		combat.combat_start()
	_turn_start()

## 回合开始
func _turn_start() -> void:
	_turn_count += 1
	print(_turn_count, "回合开始===================")
	turn_started.emit(_turn_count)
	var cs := combats.duplicate()
	cs.shuffle()
	cs.sort_custom(
		func(a: CombatComponent, b: CombatComponent) -> bool:
			if not a or not b: return false
			return a.speed > b.speed
	)
	for combat in cs:
		if not is_instance_valid(combat): continue
		if not combat.is_alive: continue
		await combat.turn_start()
	_turn_end()

## 回合结束
func _turn_end() -> void:
	if get_tree().get_node_count_in_group("Enemy") <= 0:
		_combat_finish()
	elif get_tree().get_node_count_in_group("Player") <= 0:
		_combat_defeat()
	else:
		if _turn_count >= max_turn_count:
			print("回合数耗尽")
			_combat_defeat()
		for combat in combats:
			if not is_instance_valid(combat): continue
			combat.turn_end()
		print("回合结束===================")
		turn_ended.emit()
		_turn_start()

## 战斗胜利
func _combat_finish() -> void:
	for combat in combats:
		if not combat : continue
		combat.combat_end()
	print("===== 战斗胜利 =====, 回合数： ", _turn_count)
	combat_finished.emit()

## 战斗失败
func _combat_defeat() -> void:
	for combat in combats:
		if not combat : continue
		combat.combat_end()
	print("===== 战斗失败 =====, 回合数： ", _turn_count)
	combat_defeated.emit()
