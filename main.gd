extends Node2D

@onready var rich_text_label: RichTextLabel = %RichTextLabel

func _ready() -> void:
	CombatSystem.combat_started.connect(
		func() -> void:
			rich_text_label.text += "战斗开始\n"
	)
	CombatSystem.turn_started.connect(
		func(turn_count: int) -> void:
			rich_text_label.text += "{0}回合开始\n".format([
				turn_count,
			])
	)
	CombatSystem.turn_ended.connect(
		func() -> void:
			rich_text_label.text += "回合结束\n"
	)
	CombatSystem.combat_finished.connect(
		func() -> void:
			rich_text_label.text += "战斗胜利\n"
	)
	CombatSystem.combat_defeated.connect(
		func() -> void:
			rich_text_label.text += "战斗失败\n"
	)
	for combat in CombatSystem.combats:
		combat.hited.connect(
			func(target: CombatComponent) -> void:
				rich_text_label.text += "{0} 攻击 {1}\n".format([
					combat.owner, target.owner
				])
		)
		combat.hurted.connect(
			func(damage: int) -> void:
				rich_text_label.text += "{0} 受到{1}点伤害！\n".format([
					combat.owner, damage
				])
		)
	CombatSystem.combat_start()
