extends Node2D
class_name CombatScene

## 战斗场景，负责处理战斗的表现层面

const CHARACTER = preload("res://scenes/character/character.tscn")

# 测试用角色
@onready var enemy_markers: Node2D = %EnemyMarkers
@onready var player_markers: Node2D = %PlayerMarkers
@onready var ui_combat_scene: UICombatScene = $UILayer/UICombatScene

@export var combat_test_id : StringName

var _logger: CoreSystem.Logger = CoreSystem.logger

## 战斗管理器实例
var combat_manager: CombatManager

func _ready() -> void:
	var player_character = get_node(^"PlayerMarkers/Marker2D/PlayerCharacter")
	player_character.get_parent().remove_child(player_character)
	player_character.queue_free()

# 初始化状态，在ready之前执行
func init_state(data: Dictionary) -> void:
	var combat_info : CombatModel = data.get("combat_info", null)
	if not combat_info:
		_logger.error("战斗数据为空！尝试加载测试数据")
		combat_info = DataManager.get_data_model("combat", "test")
	
	if not combat_info:
		_logger.error("无法加载测试战斗数据")
		return
	
	# 初始化战斗
	_initialize_combat(combat_info)

## 初始化战斗
func _initialize_combat(combat_info: CombatModel) -> void:
	if not is_node_ready():
		await ready
	# 1. 创建并设置战斗单位
	var player_units : Array[Character] = _setup_player_units()
	var enemy_units : Array[Character] = _setup_enemy_units(combat_info)
	
	var player_combats : Array[CombatComponent] = []
	var enemy_combats : Array[CombatComponent] = []

	for player_unit in player_units:
		var player_logic: CharacterLogic = player_unit.character_logic
		var combat_component : CombatComponent = player_logic.get_component("combat_component")
		player_combats.append(combat_component)

	for enemy_unit in enemy_units:
		var entity_logic: CharacterLogic = enemy_unit.character_logic
		var combat_component : CombatComponent = entity_logic.get_component("combat_component")
		enemy_combats.append(combat_component)

	# 2. 创建战斗管理器
	combat_manager = CombatSystem.create_combat(player_combats, enemy_combats, combat_info)
	_connect_combat_signals()
	_setup_scene()
	_setup_ui()

## 创建玩家单位
func _setup_player_units() -> Array[Character]:
	# 获取当前队伍
	var party = PartySystem.get_active_party()
	
	for i in range(party.size()):
		var character = party[i]
		if not character:
			continue
		
		# 设置位置
		if player_markers and player_markers.get_child_count() > i:
			var marker = player_markers.get_child(i)
			# character.global_position = marker.global_position
			marker.add_child(character)
	
	return party

## 创建敌人单位
func _setup_enemy_units(combat_info: CombatModel) -> Array[Character]:
	var units: Array[Character] = []
	
	for i in range(combat_info.enemy_data.size()):
		var entityID : StringName = combat_info.enemy_data[i]
		if entityID.is_empty():
			continue
		
		var character: Character = CharacterSystem.create_character(entityID)
		# 设置位置
		if enemy_markers and enemy_markers.get_child_count() > i:
			var marker = enemy_markers.get_child(i)
			# character.global_position = marker.global_position
			marker.add_child(character)
					
			# 3. 连接角色信号
			_connect_character_signals(character)
		units.append(character)
	return units

## 连接角色信号
func _connect_character_signals(character: Character) -> void:
	pass

## 角色死亡回调
func _on_character_died(character: Character) -> void:
	# 处理角色死亡的表现效果
	pass

## 连接战斗信号
func _connect_combat_signals() -> void:
	if not combat_manager:
		return
		
	combat_manager.combat_started.connect(_on_combat_started)
	combat_manager.turn_prepared.connect(_on_turn_prepared)
	combat_manager.turn_started.connect(_on_turn_started)
	combat_manager.turn_ended.connect(_on_turn_ended)
	combat_manager.combat_finished.connect(_on_combat_finished)
	combat_manager.combat_defeated.connect(_on_combat_defeated)
	combat_manager.combat_ended.connect(_on_combat_ended)
	combat_manager.action_ready.connect(_on_action_ready)

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

## 战斗开始回调
func _on_combat_started() -> void:
	# 处理战斗开始的表现效果
	pass

## 回合准备回调
func _on_turn_prepared() -> void:
	pass

## 回合开始回调
func _on_turn_started(turn_count: int) -> void:
	pass

## 回合结束回调
func _on_turn_ended() -> void:
	pass

## 战斗胜利回调
func _on_combat_finished() -> void:
	# 显示胜利界面
	if ui_combat_scene:
		ui_combat_scene.show_victory_ui()

## 战斗失败回调
func _on_combat_defeated() -> void:
	# 显示失败界面
	if ui_combat_scene:
		ui_combat_scene.show_defeat_ui()

## 战斗结束回调
func _on_combat_ended() -> void:
	# 处理战斗结束的清理工作
	pass

## 行动准备回调
func _on_action_ready(unit: CombatComponent) -> void:
	# 显示行动选择UI
	if ui_combat_scene:
		ui_combat_scene.show_action_selection(unit)
