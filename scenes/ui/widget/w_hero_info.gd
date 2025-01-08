extends PanelContainer
class_name W_HeroInfo

const W_SKILL_ICON = preload("res://addons/godot_gameplay_ability_system/source/scene/widget/w_skill_icon.tscn")

@onready var texture_rect_hero_icon: TextureRect = %TextureRectHeroIcon
@onready var label_hero_name: Label = %LabelHeroName
@onready var attribute_container: GridContainer = %AttributeContainer
@onready var skill_container: HBoxContainer = %SkillContainer
@onready var w_status: W_Status = %W_Status

@export var attribute_names : PackedStringArray = [
	"生命值", "魔法值", "攻击力", "防御力", "暴击率", "命中率"
]

var _character : Character

func setup(character : Character) -> void:
	_character = character
	w_status.setup(character)
	texture_rect_hero_icon.texture = _character.character_icon
	label_hero_name.text = _character.character_name
	var ability_component := _character.ability_component
	var ability_attribute_component := _character.ability_attribute_component
	var index := 0
	for attribute_name : String in attribute_names:
		var w_attribute_label : Label = attribute_container.get_child(index)
		if ability_attribute_component.has_attribute(attribute_name):
			var attribute: AbilityAttribute = ability_attribute_component.get_attribute(attribute_name)
			var attribute_value := ability_attribute_component.get_attribute_value(attribute_name)
			w_attribute_label.text = "{0} : {1}".format([attribute_name, attribute_value])
			attribute.attribute_value_changed.connect(
				func(value: float) -> void:
					w_attribute_label.text = "{0} : {1}".format([attribute_name, value])
			)
		else:
			w_attribute_label.text = ""
		index += 1
	index = 0
	for ability : Ability in ability_component.get_abilities():
		if ability is SkillAbility and ability.is_show:
			var w_skill : W_SkillIcon = skill_container.get_child(index)
			if w_skill:
				w_skill.setup(ability)
			index += 1
