extends Node2D

const GameStateMachine = preload("res://scripts/state_machine/game_state_machine.gd")

var _state_machine_manager: CoreSystem.StateMachineManager = CoreSystem.state_machine_manager
var _logger: CoreSystem.Logger = CoreSystem.logger
var _scene_manager : CoreSystem.SceneManager

@export var scenes : Dictionary[StringName, String] = {
	&"menu": "res://scenes/core/menu_scene.tscn",
	&"game": "res://scenes/core/game_scene.tscn"
}
@export var _action_table_type : TableType
@export var _ability_model_types : Array[ModelType]
@export var _character_model_type : ModelType = load("res://resources/character_model_type.tres")
@export var _combat_model_type : ModelType = load("res://resources/combat_model_type.tres")
var _initialized : bool = false

## 初始化完成信号
signal initialized
## 场景切换完成
signal scene_changed(old_scene: Node, new_scene: Node)

func _ready() -> void:
	_scene_manager = CoreSystem.scene_manager
	AbilitySystem.initialized.connect(
		func(success: bool):
			ItemSystem.initialize()
	)
	ItemSystem.initialized.connect(
		func(success: bool):
			CharacterSystem.initialize(_character_model_type)
	)
	CharacterSystem.initialized.connect(
		func(initialized: bool):
			CombatSystem.initialize(_combat_model_type)
	)
	CombatSystem.initialized.connect(
		func(is_initialized: bool):
			# _initialize_data_model()
			_initialized = true
			initialized.emit()
	)
	_scene_manager.scene_changed.connect(_on_scene_changed)
	_initialize_scene()
	_state_machine_manager.register_state_machine(
		"game_state_machine",
		GameStateMachine.new(),
		self,
		"launch"
	)

func initialize() -> void:
	if _initialized:
		_logger.error("Game is already initialized")
		return
	# 初始化子模块
	AbilitySystem.initialize(_ability_model_types, _action_table_type)

## 切换场景
func change_scene(scene_name : StringName) -> void:
	_scene_manager.change_scene_async(scenes.get(scene_name))

## 显示菜单scene
func show_menu() -> void:
	# change_scene(&"menu")
	pass

## 开始游戏
func play_game() -> void:
	PartySystem.initialize()

## 初始化场景
func _initialize_scene() -> void:
	for key in scenes.keys():
		var scene_path = scenes[key]
		_scene_manager.preload_scene(scene_path)

## 场景切换回调
func _on_scene_changed(old_scene: Node, new_scene: Node) -> void:
	scene_changed.emit(old_scene, new_scene)
