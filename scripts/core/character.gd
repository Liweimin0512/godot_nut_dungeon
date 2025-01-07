extends Node2D
class_name Character

## 战斗角色

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var combat_component: CombatComponent = $CombatComponent
@onready var ability_component: AbilityComponent = %AbilityComponent
@onready var w_status: W_Status = $W_Status

@export var character_model : CharacterModel
## 角色阵营
@export var character_camp: CombatDefinition.COMBAT_CAMP_TYPE = CombatDefinition.COMBAT_CAMP_TYPE.PLAYER
## 角色头像
@export var character_icon : Texture2D

# 角色的名称
var character_name : String = ""

func _ready() -> void:
	pass

func setup() -> void:
	if character_model:
		#character_model = character_model.duplicate()
		character_name = character_model.character_name
		ability_component.initialization(
			character_model.ability_attributes,
			character_model.ability_resources,
			character_model.abilities,
			{
				"caster": combat_component,
				"ability_component": ability_component
			}
		)
		combat_component.initialization(character_camp)
		_animation_player_setup()
		character_icon = character_model.character_icon
		$Sprite2D.position = character_model.sprite_position
	if character_camp == CombatDefinition.COMBAT_CAMP_TYPE.ENEMY:
		$Sprite2D.flip_h = true
	w_status.setup(self)

func _animation_player_setup() -> void:
	animation_player.remove_animation_library("")
	animation_player.add_animation_library("", character_model.animation_library)
	for animation in animation_player.get_animation_list():
		if animation != "die":
			animation_player.animation_set_next(animation, "idle")
	animation_player.stop()
	animation_player.play("idle")

func _to_string() -> String:
	return character_name

func _on_area_2d_mouse_entered() -> void:
	print("_on_area_2d_mouse_entered：", self.name)

func _on_ability_component_resource_changed(res_name: StringName, _value: float) -> void:
	if res_name == "生命值":
		if not combat_component: combat_component = $CombatComponent

func _on_combat_component_died() -> void:
	animation_player.play("die")
	await animation_player.animation_finished

func _on_combat_component_hited(_target: CombatComponent) -> void:
	pass

func _on_combat_component_hurted(_damage: int) -> void:
	animation_player.play("hit")

func _on_ability_component_pre_cast(ability: Ability) -> void:
	%LabelAbility.text = ability.ability_name
	%LabelAbility.show()
	await get_tree().create_timer(1).timeout
	%LabelAbility.hide()
