extends Node2D
class_name CombatScene

## 战斗场景，负责处理战斗的表现层面

const CHARACTER = preload("res://scenes/character/character.tscn")

# 测试用角色
@onready var enemy_markers: Node2D = %EnemyMarkers
@onready var player_markers: Node2D = %PlayerMarkers
#@onready var ui_combat_scene: UICombatScene = $UILayer/UICombatScene
@onready var action_layer: CanvasLayer = $ActionLayer
@onready var camera_2d: Camera2D = $Camera2D

@export var combat_test_id : StringName
@export var action_position_y : float = 240.0

var _logger: CoreSystem.Logger = CoreSystem.logger

func _ready() -> void:
	CombatSystem.action_ability_selected.subscribe(_on_action_ability_selected)
	CombatSystem.combat_action_started.subscribe(_on_combat_action_started)

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

	# 2. 创建战斗管理器
	CombatSystem.create_combat(combat_id)
	
	_setup_scene()
	_setup_camera()
	_setup_ui()

	# 3. 开始战斗
	CombatSystem.start_combat()

## 设置场景
func _setup_scene() -> void:
	# 创建并布置战斗单位
	_setup_combat_units(CombatSystem.players, CombatSystem.enemies)
	
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
	pass

## 移除测试角色
func _remove_test_characters() -> void:
	for marker in player_markers.get_children() + enemy_markers.get_children():
		for child in marker.get_children():
			marker.remove_child(child)
			child.queue_free()
	for child in action_layer.get_children():
		action_layer.remove_child(child)
		child.queue_free()

## 设置战斗单位位置
func _setup_combat_units(players: Array[Node], enemies: Array[Node]) -> void:
	# 设置玩家单位位置
	for i in range(players.size()):
		var character = players[i]
		if not character:
			continue
		if player_markers and player_markers.get_child_count() > i:
			var marker : Marker2D = player_markers.get_child(i)
			marker.add_child(character)
		if not character.pressed.is_connected(_on_character_pressed):
			character.pressed.connect(_on_character_pressed.bind(character))
			
	# 设置敌人单位位置
	for i in range(enemies.size()):
		var character = enemies[i]
		if not character:
			continue
		if enemy_markers and enemy_markers.get_child_count() > i:
			var marker : Marker2D = enemy_markers.get_child(i)
			marker.add_child(character)
		if not character.pressed.is_connected(_on_character_pressed):
			character.pressed.connect(_on_character_pressed.bind(character))

#endregion


func _on_action_ability_selected() -> void:
	var actor : Character = CombatSystem.current_actor
	var current_action : CombatAction = CombatSystem.current_action
	if not actor:
		push_error("actor is null")
		return
	var ability = current_action.ability
	var targets := ability.get_available_targets({"caster": actor})
	for target in targets:
		target.can_select = true


func _on_combat_action_started() -> void:
	var action := CombatSystem.current_action
	for unit in action.targets:
		unit.can_select = false


func _on_character_pressed(character : Character) -> void:
	if character.can_select:
		CombatSystem.select_target(character)
		CombatSystem.action_target_selected.push()
