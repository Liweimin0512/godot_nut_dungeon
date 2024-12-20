extends Node2D

@onready var rich_text_label: RichTextLabel = %RichTextLabel


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
