extends Node2D
class_name Character

## 战斗角色

@export var character_model : CharacterModel

@onready var label_name: Label = %LabelName
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar: ProgressBar = $MarginContainer/ProgressBar
@onready var label_health: Label = %LabelHealth
@onready var label_action: Label = %LabelAction
@onready var combat_component: CombatComponent = $CombatComponent
@onready var ability_component: AbilityComponent = %AbilityComponent

# 角色的名称
var cha_name : String = ""

func _ready() -> void:
	if character_model:
		character_model = character_model.duplicate()
		cha_name = character_model.character_name
		_initialization_ability_component()
		_initialization_combat_component()
	label_name.text = cha_name
	progress_bar.max_value = ability_component.max_health
	progress_bar.value = ability_component.current_health
	label_health.text = "{0}/{1}".format([
		ability_component.current_health,
		ability_component.max_health 
		])

func _initialization_ability_component() -> void:
	ability_component.max_health = character_model.max_health
	ability_component.attack_power = character_model.attack_power
	ability_component.defense_power = character_model.defense_power
	ability_component.speed = character_model.speed
	#ability_component.current_health = ability_component.max_health
	#ability_component.abilities = character_model.abilities
	ability_component.ability_resources = character_model.ability_resources
	ability_component.initialization()

func _initialization_combat_component() -> void:
	combat_component.camp = character_model.camp
	combat_component.initialization()

func _on_combat_component_current_health_changed(value: float) -> void:
	if not progress_bar: progress_bar = $MarginContainer/ProgressBar
	if not combat_component: combat_component = $CombatComponent
	progress_bar.value = ability_component.current_health
	if not label_health : label_health = %LabelHealth
	label_health.text = "{0}/{1}".format([
		ability_component.current_health,
		ability_component.max_health 
		])

func _on_combat_component_died() -> void:
	animation_player.play("die")
	await animation_player.animation_finished

func _on_combat_component_hited(target: CombatComponent) -> void:
	label_action.text = "攻击{0}".format([target.owner])
	animation_player.play("hit")

func _on_combat_component_hurted(_damage: int) -> void:
	animation_player.play("hurt")

func _on_area_2d_mouse_entered() -> void:
	print("_on_area_2d_mouse_entered：", self.name)

func _to_string() -> String:
	return cha_name
