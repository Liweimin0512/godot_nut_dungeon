extends Node2D

@export var max_turn_count: int = 99
var _combat_characters : Array[Character]
var _turn_count : int = 0

func _ready() -> void:
	_combat_start()

## 战斗开始
func _combat_start() -> void:
	print("战斗开始！")
	for cha in get_tree().get_nodes_in_group("Character"):
		_combat_characters.append(cha as Character)
	for character in _combat_characters:
		character.combat_start()
	_turn_start()

## 回合开始
func _turn_start() -> void:
	_turn_count += 1
	print(_turn_count, "回合开始===================")
	_combat_characters.shuffle()
	_combat_characters.sort_custom(
		func(a: Character, b: Character) -> bool:
			return a.speed > b.speed
	)
	for character in _combat_characters:
		if not is_instance_valid(character): continue
		if not character.is_alive: continue
		character.turn_start()
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
		for character in _combat_characters:
			character.turn_end()
		print("回合结束===================")
		_turn_start()

## 战斗胜利
func _combat_finish() -> void:
	for cha in _combat_characters:
		cha.combat_end()
	print("===== 战斗胜利 =====, 回合数： ", _turn_count)

## 战斗失败
func _combat_defeat() -> void:
	for cha in _combat_characters:
		cha.combat_end()
	print("===== 战斗失败 =====, 回合数： ", _turn_count)
