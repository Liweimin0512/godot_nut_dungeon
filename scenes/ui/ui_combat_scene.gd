extends Control
class_name UICombatScene

const W_HERO_INFO = preload("res://scenes/ui/widget/w_hero_info.tscn")

@onready var w_hero_info_container: HBoxContainer = %W_HeroInfoContainer
@onready var rich_text_label: RichTextLabel = %RichTextLabel

var _players : Array[Character]

func _ready() -> void:
	rich_text_label.text = ""

func setup(players: Array[Character] = []) -> void:
	_players = players
	w_hero_info_container.remove_child(w_hero_info_container.get_child(0))
	for player in _players:
		var w_hero_info : W_HeroInfo = W_HERO_INFO.instantiate()
		w_hero_info_container.add_child(w_hero_info)
		w_hero_info.setup(player)

func handle_game_event(event_name: StringName, event_data: Dictionary = {}) -> void:
	match event_name:
		"game_start":
			rich_text_label.text += "战斗开始\n"
		"game_end":
			rich_text_label.text += "战斗结束\n"
		"turn_start":
			rich_text_label.text += "{0}回合开始\n".format([event_data.turn_count])
		"turn_end":
			rich_text_label.text += "回合结束\n"
		"combat_win":
			rich_text_label.text += "战斗胜利\n"
		"combat_defeated":
			rich_text_label.text += "战斗失败\n"
		"combat_hit":
			rich_text_label.text += "{0} 攻击 {1}\n".format([event_data.owner, event_data.target])
		"combat_hurt":
			rich_text_label.text += "{0} 受到{1}点伤害！\n".format([event_data.owner, event_data.damage])
		"combat_ability_cast":
			rich_text_label.text += "{0} 释放 {1} 技能！\n".format([event_data.owner, event_data.ability])
