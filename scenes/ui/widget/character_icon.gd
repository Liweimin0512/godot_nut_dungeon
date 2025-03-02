extends MarginContainer
class_name CharacterIcon

@onready var texture_rect: TextureRect = %TextureRect
#@onready var ui_widget_component: UIWidgetComponent = $UIWidgetComponent

func setup(unit: Node2D) -> void:
	var character : Character = unit
	texture_rect.texture = character.character_icon
