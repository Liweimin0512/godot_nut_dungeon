extends Node
class_name W_Status

const W_BUFF = preload("res://source/widget/w_buff.tscn")
const W_ABILITY_RESOURCE = preload("res://source/widget/w_ability_resource.tscn")

@onready var v_box_container: VBoxContainer = %VBoxContainer
@onready var w_buff_container: MarginContainer = %W_BuffContainer
@onready var grid_container: GridContainer = %GridContainer

var _character: Character

func setup(character : Character) -> void:
	_character = character
	var ability_component : AbilityComponent = _character.ability_component
	$VBoxContainer/W_AbilityResource.queue_free()
	for res : AbilityResource in ability_component.get_resources():
		var w_res : W_AbilityResource = W_ABILITY_RESOURCE.instantiate()
		v_box_container.add_child(w_res)
		w_res.setup(res)
	ability_component.ability_applied.connect(
		func(ability: Ability) -> void:
			if ability is BuffAbility: add_buff(ability)
	)
	ability_component.ability_removed.connect(
		func(ability: Ability) -> void:
			if ability is BuffAbility: remove_buff(ability)
	)
	w_buff_container.move_to_front()

func add_buff(buff: BuffAbility) -> void:
	var w_buff : W_Buff = W_BUFF.instantiate()
	grid_container.add_child(w_buff)
	w_buff.setup(buff)

func get_buff(buff: BuffAbility) -> W_Buff:
	for w_buff : W_Buff in grid_container.get_children():
		if w_buff.buff == buff:
			return w_buff
	return null

func remove_buff(buff: BuffAbility) -> void:
	var w_buff := get_buff(buff)
	if w_buff:
		grid_container.remove_child(w_buff)
		w_buff.queue_free()
