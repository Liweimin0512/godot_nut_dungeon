extends Node2D
class_name Character

## 战斗角色

@onready var label_name: Label = %LabelName
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar: ProgressBar = $MarginContainer/ProgressBar
@onready var label_health: Label = %LabelHealth
@onready var label_action: Label = %LabelAction
@onready var combat_component: CombatComponent = $CombatComponent


# 角色的名称
@export var cha_name : String = ""
var is_alive : bool :
	get:
		return _current_health > 0

func _ready() -> void:
	_current_health = max_health
	label_name.text = cha_name
	hited.connect(
		func(target: Character) -> void:
			label_action.text = "攻击{0}".format([target])
			animation_player.play("hit")
	)
	hurted.connect(
		func(_damage) -> void:
			animation_player.play("hurt")
	)
	progress_bar.max_value = max_health
	progress_bar.value = _current_health
	label_health.text = "{0}/{1}".format([_current_health,max_health ])

func _to_string() -> String:
	#return "name : {cha_name} speed : {speed} health : {health} attack : {attack} defense : {defense}".format({
		#"cha_name": cha_name,
		#"speed": speed,
		#"health": _current_health,
		#"attack": attack_power,
		#"defense": defense_power,
	#})
	return cha_name
