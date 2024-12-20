extends Node2D

@onready var rich_text_label: RichTextLabel = $CanvasLayer/RichTextLabel

@export var max_turn_count: int = 99
var _combat_characters : Array[Character]
var _turn_count : int = 0

signal combat_started
signal turn_started
signal turn_ended
signal combat_finished
signal combat_defeated

func _ready() -> void:
	combat_started.connect(
		func() -> void:
			rich_text_label.text += "战斗开始\n"
	)
	turn_started.connect(
		func(turn_count: int) -> void:
			rich_text_label.text += "{0}回合开始\n".format([
				turn_count,
			])
	)
	turn_ended.connect(
		func() -> void:
			rich_text_label.text += "回合结束\n"
	)
	combat_finished.connect(
		func() -> void:
			rich_text_label.text += "战斗胜利\n"
	)
	combat_defeated.connect(
		func() -> void:
			rich_text_label.text += "战斗失败\n"
	)
	_combat_start()

## 战斗开始
func _combat_start() -> void:
	print("战斗开始！")
	combat_started.emit()
	for cha : Character in get_tree().get_nodes_in_group("Character"):
		_combat_characters.append(cha as Character)
		cha.hited.connect(
			func(target: Character) -> void:
				rich_text_label.text += "{0} 攻击 {1}\n".format([
					cha, target
				])
		)
		cha.hurted.connect(
			func(damage: int) -> void:
				rich_text_label.text += "{0} 受到{1}点伤害！\n".format([
					cha, damage
				])
		)
	for character in _combat_characters:
		character.combat_start()
	_turn_start()

## 回合开始
func _turn_start() -> void:
	_turn_count += 1
	print(_turn_count, "回合开始===================")
	turn_started.emit(_turn_count)
	_combat_characters.shuffle()
	_combat_characters.sort_custom(
		func(a: Character, b: Character) -> bool:
			if not a or not b: return false
			return a.speed > b.speed
	)
	for character in _combat_characters:
		if not is_instance_valid(character): continue
		if not character.is_alive: continue
		await character.turn_start()
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
			if not is_instance_valid(character): continue
			character.turn_end()
		print("回合结束===================")
		turn_ended.emit()
		_turn_start()

## 战斗胜利
func _combat_finish() -> void:
	for cha in _combat_characters:
		if not cha : continue
		cha.combat_end()
	print("===== 战斗胜利 =====, 回合数： ", _turn_count)
	combat_finished.emit()

## 战斗失败
func _combat_defeat() -> void:
	for cha in _combat_characters:
		if not cha : continue
		cha.combat_end()
	print("===== 战斗失败 =====, 回合数： ", _turn_count)
	combat_defeated.emit()
