extends Node2D
class_name Character

## 战斗角色

@onready var label_name: Label = %LabelName
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar: ProgressBar = $MarginContainer/ProgressBar
@onready var label_health: Label = %LabelHealth
@onready var label_action: Label = %LabelAction
@onready var combat_component: CombatComponent = $CombatComponent
@onready var ability_component: AbilityComponent = %AbilityComponent


@export var character_model : CharacterModel
@export var character_camp: CombatDefinition.COMBAT_CAMP_TYPE = CombatDefinition.COMBAT_CAMP_TYPE.PLAYER

# 角色的名称
var cha_name : String = ""

func _ready() -> void:
	if character_model:
		character_model = character_model.duplicate()
		cha_name = character_model.character_name
		ability_component.initialization(
			character_model.ability_attributes,
			character_model.ability_resources,
			character_model.abilities
		)
		combat_component.initialization(character_camp)
		animation_player.remove_animation_library("")
		animation_player.add_animation_library("", character_model.animation_library)
		$Sprite2D.position = character_model.sprite_position
	label_name.text = cha_name
	progress_bar.max_value = ability_component.get_attribute_value("生命值")
	progress_bar.value = ability_component.get_resource_value("生命值")
	label_health.text = "{0}/{1}".format([
		ability_component.get_resource_value("生命值"),
		ability_component.get_attribute_value("生命值")
		])
	if character_camp == CombatDefinition.COMBAT_CAMP_TYPE.ENEMY:
		$Sprite2D.flip_h = true

func _on_area_2d_mouse_entered() -> void:
	print("_on_area_2d_mouse_entered：", self.name)

func _on_ability_component_resource_changed(res_name: StringName, value: float) -> void:
	if res_name == "生命值":
		if not progress_bar: progress_bar = $MarginContainer/ProgressBar
		if not combat_component: combat_component = $CombatComponent
		if not label_health : label_health = %LabelHealth
		progress_bar.value = value
		label_health.text = "{0}/{1}".format([
			ability_component.get_resource_value("生命值"),
			ability_component.get_attribute_value("生命值")
			])

func _on_combat_component_died() -> void:
	animation_player.play("die")
	await animation_player.animation_finished

func _on_combat_component_hited(target: CombatComponent) -> void:
	label_action.text = "攻击{0}".format([target.owner])
	animation_player.play("hit")

func _on_combat_component_hurted(_damage: int) -> void:
	animation_player.play("hurt")

func _to_string() -> String:
	return cha_name
