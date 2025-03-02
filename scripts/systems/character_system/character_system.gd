extends Node

## 角色系统
## 负责管理角色的生命周期、加载和创建

const CHARACTER_SCENE_PATH = "res://scenes/character/character.tscn"
const CHARACTER : StringName = "character"

## 角色加载完成信号
signal character_loaded(character_id: StringName, character: Node)
## 角色创建完成信号
signal character_created(character_id: StringName, character: Node)
## 角色销毁信号
signal character_destroyed(character_id: StringName, character: Node)
signal initialized(success: bool)

var _initialized: bool = false

var _entity_manager: CoreSystem.EntityManager:
	get:
		return CoreSystem.entity_manager
var _logger: CoreSystem.Logger:
	get:
		return CoreSystem.logger
var _character_data_model : ModelType

func _ready() -> void:
	_entity_manager.entity_loaded.connect(
		func(entity_id: StringName, entity: Node):
			if _entity_manager._entity_path_map[entity_id] == CHARACTER_SCENE_PATH:
				character_loaded.emit(entity_id, entity)
	)
	_entity_manager.entity_created.connect(
		func(entity_id: StringName, entity: Node):
			if _entity_manager._entity_path_map[entity_id] == CHARACTER_SCENE_PATH:
				character_created.emit(entity_id, entity)
	)
	_entity_manager.entity_destroyed.connect(
		func(entity_id: StringName, entity: Node):
			if _entity_manager._entity_path_map[entity_id] == CHARACTER_SCENE_PATH:
				character_destroyed.emit(entity_id, entity)
	)

## 初始化系统
func initialize(character_model_type: ModelType) -> bool:
	if _initialized:
		return true
	# 检查依赖关系是否满足
	DataManager.load_model(character_model_type,
		func(result: Variant):
			print(result)
			_entity_manager.load_entity(CHARACTER, CHARACTER_SCENE_PATH, CoreSystem.ResourceManager.LOAD_MODE.IMMEDIATE)
			_initialized = true
			initialized.emit(_initialized)
	)
	_character_data_model = character_model_type
	return true

## 创建角色
## [param character_id] 角色ID
## [param parent] 父节点
## [return] 创建的角色实例
func create_character(character_id: StringName, parent: Node = null) -> Node:
	var character_config : Resource = DataManager.get_data_model(_character_data_model.model_name, character_id)
	var character = _entity_manager.create_entity(CHARACTER, character_config, parent)
	if not character:
		_logger.error("can not create character: {0}".format([character_id]))
		return null
	if "character_logic" in character:
		character.character_logic.initialize({
			"character_config": character_config,
			"character_camp": character_config.camp,
		})
	return character

## 销毁角色
## [param character_id] 角色ID
## [param instance] 要销毁的角色实例
func destroy_character(character_id: StringName, instance: Node) -> void:
	_entity_manager.destroy_entity(character_id, instance)

## 清理所有角色
func clear_characters() -> void:
	_entity_manager.clear_entities()
