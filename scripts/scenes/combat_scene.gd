extends Node2D
class_name CombatScene

## 战斗场景，负责处理战斗的表现层面

const CHARACTER = preload("res://scenes/character/character.tscn")

# 测试用角色
@onready var enemy_markers: Node2D = %EnemyMarkers
@onready var player_markers: Node2D = %PlayerMarkers
@onready var ui_combat_scene: UICombatScene = $UILayer/UICombatScene
@onready var action_layer: CanvasLayer = $ActionLayer
@onready var camera_2d: Camera2D = $Camera2D

@export var combat_test_id : StringName
@export var action_position_y : float = 240.0

var _logger: CoreSystem.Logger = CoreSystem.logger

## 战斗管理器实例
var combat_manager: CombatManager

func _ready() -> void:
	# 移除测试数据
	_remove_test_characters()

# 初始化状态，在ready之前执行
func init_state(data: Dictionary) -> void:
	# var combat_info : CombatModel = data.get("combat_info", null)
	var combat_id : StringName = data.get("combat_id", null)
	if not combat_id:
		_logger.error("战斗数据为空！尝试加载测试数据")
		combat_id = "test"
	
	if not combat_id:
		_logger.error("无法加载测试战斗数据")
		return
	
	# 初始化战斗
	_initialize_combat(combat_id)

#region 内部方法，不要调用

## 初始化战斗
func _initialize_combat(combat_id: StringName) -> void:
	if not is_node_ready():
		# 等待节点准备好
		await ready

	# 1. 创建并设置战斗单位
	var player_units : Array = _setup_player_units()
	var enemy_units : Array = _setup_enemy_units(combat_id)

	var players : Array[Node]
	for unit in player_units:
		players.append(unit)
	var enemies : Array[Node]
	for unit in enemy_units:
		enemies.append(unit)

	# 2. 创建战斗管理器
	combat_manager = CombatSystem.create_combat(combat_id, players, enemies)
	# TODO 测试修改
	combat_manager._combat_config.is_auto = false
	
	_setup_scene()
	_setup_camera()
	_setup_ui()

	# 3. 开始战斗
	CombatSystem.start_combat()

## 创建玩家单位
func _setup_player_units() -> Array:
	# 获取当前队伍
	var party = PartySystem.get_active_party()
	
	for i in range(party.size()):
		var character = party[i]
		if not character:
			continue
		_setup_character(character, i, CombatDefinition.COMBAT_CAMP_TYPE.PLAYER)
	return party

## 创建敌人单位
func _setup_enemy_units(combat_id: StringName) -> Array:
	var units: Array = []

	var combat_info : CombatModel = CombatSystem.get_combat_config(combat_id)
	
	for i in range(combat_info.enemy_data.size()):
		var entityID : StringName = combat_info.enemy_data[i]
		if entityID.is_empty():
			continue
		
		var character: Character = CharacterSystem.create_character(entityID)
		_setup_character(character, i, CombatDefinition.COMBAT_CAMP_TYPE.ENEMY)
		units.append(character)
	return units

func _setup_character(character : Character, index : int, character_camp : CombatDefinition.COMBAT_CAMP_TYPE) -> void:
	# 战斗点位设置
	character.combat_point = index + 1
	# 显示位置设置
	var markers : Node2D = enemy_markers if character_camp == CombatDefinition.COMBAT_CAMP_TYPE.ENEMY else player_markers
	if markers and markers.get_child_count() > index:
		var marker : Marker2D = markers.get_child(index)
		marker.add_child(character)

## 设置场景
func _setup_scene() -> void:
	# 创建并布置战斗单位
	# _setup_battle_units()
	
	# 设置战斗相机
	# _setup_camera()
	
	# 其他场景设置...
	pass

## 设置相机
func _setup_camera() -> void:
	# 设置战斗相机
	pass

## 设置UI
func _setup_ui() -> void:
	if ui_combat_scene:
		ui_combat_scene.setup(combat_manager)

## 移除测试角色
func _remove_test_characters() -> void:
	for marker in player_markers.get_children() + enemy_markers.get_children():
		for child in marker.get_children():
			marker.remove_child(child)
			child.queue_free()
	for child in action_layer.get_children():
		action_layer.remove_child(child)
		child.queue_free()

#endregion
