extends Node2D

const GAME_SCENE = preload("res://scenes/core/game_scene.tscn")
const GameStateMachine = preload("res://scripts/state_machine/game_state_machine.gd")

@export var table_types : TableTypes = preload("res://resources/data/table_types.tres")
var _state_machine_manager: CoreSystem.StateMachineManager = CoreSystem.state_machine_manager

func _ready() -> void:
	_state_machine_manager.register_state_machine(
		"game_state_machine",
		GameStateMachine.new(null, self),
		"launch"
	)

## 开始游戏
func play_game() -> void:
	var game_scene = GAME_SCENE.instantiate()
	add_child(game_scene)
