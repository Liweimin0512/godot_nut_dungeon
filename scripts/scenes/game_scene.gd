extends Node2D

const combat_scene_path: String = "res://scenes/core/combat_scene.tscn"

@export var test_combat: CombatModel

var _scene_manager: CoreSystem.SceneManager:
	get:
		return CoreSystem.scene_manager
	set(_value):
		push_error("scene_manager is read-only")

var _state_machine_manager: CoreSystem.StateMachineManager:
	get:
		return CoreSystem.state_machine_manager
	set(_value):
		push_error("state_machine_manager is read-only")

func _ready() -> void:
	_state_machine_manager.register_state_machine(
			"gameplay", 
			GameplayStateMachine.new(),
			self,
			"explore",
			{
				"combat_info" : test_combat
			}
		)

## 初始化战斗
func initialize_battle() -> void:
	#_scene_manager.preload_scene(battle_scene_path)
	pass

## 进入战斗
func enter_battle(data: Dictionary = {}) -> void:
	_scene_manager.change_scene_async(
		combat_scene_path, 
		data,
		true,
		_scene_manager.TransitionEffect.FADE,
		1.0
		)

## 退出战斗
func exit_battle() -> void:
	_scene_manager.pop_scene_async(
		_scene_manager.TransitionEffect.FADE,
		1.0
	)
