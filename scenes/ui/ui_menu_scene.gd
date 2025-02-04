extends Control

@onready var _button_continue = %ButtonContinue
@onready var _button_new_game = %ButtonNewGame
@onready var _button_loadgame = %ButtonLoadgame
@onready var _button_settings = %ButtonSettings
@onready var _button_credits = %ButtonCredits
@onready var _button_quit = %ButtonQuit

@onready var ui_group_component: UIGroupComponent = $UIGroupComponent

func _ready() -> void:
	_button_continue.pressed.connect(_on_button_continue_pressed)
	_button_new_game.pressed.connect(_on_button_new_game_pressed)
	_button_loadgame.pressed.connect(_on_button_loadgame_pressed)
	_button_settings.pressed.connect(_on_button_settings_pressed)
	_button_credits.pressed.connect(_on_button_credits_pressed)
	_button_quit.pressed.connect(_on_button_quit_pressed)

func _on_button_continue_pressed() -> void:
	pass

func _on_button_new_game_pressed() -> void:
	pass

func _on_button_loadgame_pressed() -> void:
	pass

func _on_button_settings_pressed() -> void:
	ui_group_component.show_scene("settings")

func _on_button_credits_pressed() -> void:
	ui_group_component.show_scene("credits")

func _on_button_quit_pressed() -> void:
	get_tree().quit()
