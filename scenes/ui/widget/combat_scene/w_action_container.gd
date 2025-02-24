extends MarginContainer
class_name W_ActionContainer

@onready var label_ability_name: Label = %LabelAbilityName
@onready var label_ability_type: Label = %LabelAbilityType
@onready var label_valid_positions: Label = %LabelValidPositions
@onready var label_target_positions: Label = %LabelTargetPositions
@onready var hero_action_container: HBoxContainer = %HeroActionContainer
@onready var label_hit_rate: Label = %LabelHitRate
@onready var label_damage: Label = %LabelDamage
@onready var label_crit_rate: Label = %LabelCritRate
@onready var label_ability_effect_info: MarginContainer = %LabelAbilityEffectInfo

var _selected_ability : HeroAction:
	set(value):
		if _selected_ability:
			_selected_ability.cancel_selecte()
		_selected_ability = value
		if _selected_ability:
			_selected_ability.selecte()
var _ability_types : Dictionary[Ability, HeroAction]
var _selecte_hero : Character
var _combat_action : CombatAction : set = _combat_action_setter

func _ready() -> void:
	CombatSystem.combat_action_selecting.subscribe(_on_combat_action_selecting)
	for child in hero_action_container.get_children():
		child.pressed.connect(_on_hero_action_pressed.bind(child))


func _update_display(action_unit: Character) -> void:
	pass


func _selecte_ability(ability: TurnBasedSkillAbility) -> void:
	var w_ability : HeroAction = _ability_types.get(ability, null)
	if not w_ability:
		return
	_selected_ability = w_ability
	label_ability_name.text = ability.ability_name
	label_ability_type.text = "近战" if ability.is_melee else "远程"
	label_valid_positions.text = "有效位置:%s" % str(ability.position_restriction.valid_cast_positions)
	label_target_positions.text = "目标位置:%s" % str(ability.get_available_target_positions())


func _on_combat_action_selecting(action_unit: Character) -> void:
	_selecte_hero = action_unit
	var ability_component : AbilityComponent = AbilitySystem.get_ability_component(action_unit)
	var abilities := ability_component.get_abilities(["skill"])
	var index : int = 0
	for child in hero_action_container.get_children():
		var ability = abilities[index] if abilities.size() > index else null
		child.ability = ability
		_ability_types[ability] = child
		index += 1
	var combat_component: CombatComponent = CombatSystem.get_combat_component(action_unit)
	_combat_action = combat_component.current_action
	_selecte_ability(_combat_action.ability)


func _on_hero_action_pressed(action: HeroAction) -> void:
	var combat_component: CombatComponent = CombatSystem.get_combat_component(_selecte_hero)
	var combat_action : CombatAction = combat_component.current_action
	combat_action.ability = action.ability


func _on_combat_action_ability_changed() -> void:
	var ability := _combat_action.ability
	_selecte_ability(ability)


func _connect_combat_action(_combat_action : CombatAction) -> void:
	_combat_action.ability_changed.connect(_on_combat_action_ability_changed)


func _disconnect_combat_action(_combat_action: CombatAction) -> void:
	_combat_action.ability_changed.disconnect(_on_combat_action_ability_changed)


func _combat_action_setter(value : CombatAction) -> void:
	if _combat_action:
		_disconnect_combat_action(_combat_action)
	_combat_action = value
	if _combat_action:
		_connect_combat_action(_combat_action)
