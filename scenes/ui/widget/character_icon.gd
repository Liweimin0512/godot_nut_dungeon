extends MarginContainer
class_name CharacterIcon

@onready var texture_rect: TextureRect = $TextureRect
@onready var ui_widget_component: UIWidgetComponent = $UIWidgetComponent

func setup(unit: CombatComponent) -> void:
	var character : CharacterLogic = unit.owner
	texture_rect.texture = character.character_config.character_icon
	
