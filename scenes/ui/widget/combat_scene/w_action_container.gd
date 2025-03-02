extends MarginContainer
class_name W_ActionContainer

const EMPTY_POSITIONS = preload("res://assets/texture/empty_positions.png")
const TARGET_POSITIONS = preload("res://assets/texture/target_positions.png")
const VALID_POSITIONS = preload("res://assets/texture/valid_positions.png")

@onready var label_ability_name: Label = %LabelAbilityName
@onready var label_ability_type: Label = %LabelAbilityType
@onready var label_valid_positions: Label = %LabelValidPositions
@onready var label_target_positions: Label = %LabelTargetPositions
@onready var hero_action_container: HBoxContainer = %HeroActionContainer
@onready var label_hit_rate: Label = %LabelHitRate
@onready var label_damage: Label = %LabelDamage
@onready var label_crit_rate: Label = %LabelCritRate
@onready var label_ability_effect_info: MarginContainer = %LabelAbilityEffectInfo
@onready var valid_positions_container: HBoxContainer = %ValidPositionsContainer
@onready var target_positions_container: HBoxContainer = %TargetPositionsContainer

var _selected_ability : W_HeroAction:
	set(value):
		if _selected_ability:
			_selected_ability.cancel_selecte()
		_selected_ability = value
		if _selected_ability:
			_selected_ability.selecte()
# var _ability_types : Dictionary[Ability, W_HeroAction]
# var _selecte_hero : Character
# var _combat_action : CombatAction : set = _combat_action_setter

func _ready() -> void:
	hide()
	CombatSystem.combat_action_selecting.subscribe(_on_combat_action_selecting)
	for child in hero_action_container.get_children():
		child.pressed.connect(_on_w_hero_action_pressed.bind(child))


func _update_valid_positions_display(ability : TurnBasedSkillAbility) -> void:
	var valid_cast_positions := ability.position_restriction.valid_cast_positions
	label_valid_positions.text = "有效位置:%s" % str(valid_cast_positions)
	var index := 4
	for child in valid_positions_container.get_children():
		if index in valid_cast_positions:
			child.texture = VALID_POSITIONS
		else:
			child.texture = EMPTY_POSITIONS
		index -= 1

func _update_target_positions_display(ability : TurnBasedSkillAbility) -> void:
	var target_positions := ability.get_available_target_positions()
	label_target_positions.text = "目标位置:%s" % str(target_positions)
	var index = 1
	for child in target_positions_container.get_children():
		if index in target_positions:
			child.texture = TARGET_POSITIONS
		else:
			child.texture = EMPTY_POSITIONS
		index += 1


## 玩家控制角色等待行动
func _on_combat_action_selecting(action : CombatAction) -> void:
	var _current_actor := action.actor
	var ability_component : AbilityComponent = AbilitySystem.get_ability_component(_current_actor)
	var abilities := ability_component.get_abilities(["skill"])

	var index := 0
	for child in hero_action_container.get_children():
		var ability = abilities[index] if abilities.size() > index else null
		child.ability = ability
		if ability == action.ability:
			child.selected.emit()
		index += 1
	show()

func _on_w_hero_action_pressed(w_action: W_HeroAction) -> void:
	_selected_ability = w_action
	var ability : = w_action.ability
	if not ability:
		return
	label_ability_name.text = ability.ability_name
	label_ability_type.text = "近战" if ability.is_melee else "远程"
	_update_valid_positions_display(ability)
	_update_target_positions_display(ability)
	label_hit_rate.text = "命中率：{0}".format([ability.get_hit_rate(CombatSystem.current_actor)])
	label_crit_rate.text = "暴击率：{0}".format([ability.get_crit_rate(CombatSystem.current_actor)])
	label_damage.text = "伤害：{0}-{1}".format([
		ability.get_min_damage(CombatSystem.current_actor),
		ability.get_max_damage(CombatSystem.current_actor)
	])
	CombatSystem.select_ability(ability)
