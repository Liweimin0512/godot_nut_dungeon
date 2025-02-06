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
@export var _model_types : Array[ModelType]

## 初始化完成信号
signal initialized
## 场景切换完成
signal scene_changed(old_scene: Node, new_scene: Node)

func _ready() -> void:
	_state_machine_manager.register_state_machine(
		"game_state_machine",
		GameStateMachine.new(),
		self,
		"launch"
	)
	_scene_manager = CoreSystem.scene_manager
	ItemSystem.initialized.connect(_on_item_system_initialized)
	AbilitySystem.initialized.connect(_on_ability_system_initialized)
	_scene_manager.scene_changed.connect(_on_scene_changed)

func initialize() -> void:
	# 初始化子模块
	ItemSystem.initialize()

## 切换场景
func change_scene(scene_name : StringName) -> void:
	_scene_manager.change_scene_async(scenes.get(scene_name))

## 显示菜单scene
func show_menu() -> void:
	# change_scene(&"menu")
	pass

## 开始游戏
func play_game() -> void:
	# change_scene(&"game")
	pass

## ItemSystem 初始化完成
func _on_item_system_initialized(success: bool) -> void:
	if not success:
		_logger.error("ItemSystem initialized failed")
		return
	AbilitySystem.initialize(
		_ability_model_types,
		_action_table_type,
	)

## AbilitySystem 初始化完成
func _on_ability_system_initialized(success: bool) -> void:
	if not success:
		_logger.error("AbilitySystem initialized failed")
		return
	_initialize_data_model()

## 初始化数据模型
func _initialize_data_model() -> void:
	DataManager.load_models(
		_model_types, 
		func(result: Array[String]) -> void:
			_logger.info("Load Model Types Completed")
			_initialize_scene()
			)

## 初始化场景
func _initialize_scene() -> void:
	for key in scenes.keys():
		var scene_path = scenes[key]
		_scene_manager.preload_scene(scene_path)
	initialized.emit()

## 场景切换回调
func _on_scene_changed(old_scene: Node, new_scene: Node) -> void:
	scene_changed.emit(old_scene, new_scene)
