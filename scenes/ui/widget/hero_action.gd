extends MarginContainer
class_name HeroAction

@onready var texture_rect: TextureRect = $TextureRect
@onready var selector: TextureRect = $Selector

var ability : TurnBasedSkillAbility:
	set(value):
		ability = value
		if ability:
			texture_rect.texture = ability.icon
		else:
			hide()

signal pressed


func _ready() -> void:
	selector.hide()


func selecte() -> void:
	selector.show()


func cancel_selecte() -> void:
	selector.hide()


func _on_button_pressed() -> void:
	pressed.emit()
