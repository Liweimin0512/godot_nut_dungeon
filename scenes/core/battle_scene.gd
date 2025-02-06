extends Node2D
class_name BattleScene

const CHARACTER = preload("res://scenes/character/character.tscn")

@onready var enemy_markers: Node2D = $EnemyMarkers
@onready var marker_action: Marker2D = %MarkerAction
@onready var game_form: GameForm = $UILayer/GameForm

@export var combat_test_id : StringName

var _state_machine_manager: CoreSystem.StateMachineManager = CoreSystem.state_machine_manager
var _logger: CoreSystem.Logger = CoreSystem.logger

var _combat_info: CombatModel
var _combat : Combat

# 初始化状态，在ready之前执行
func init_state(data: Dictionary) -> void:
	_combat_info = data.get("combat_info", _combat_info)
	if not _combat_info:
		_logger.error("战斗数据为空！尝试加载测试数据")
		_combat_info = DataManager.get_data_model("combat", "test")
	
	if not _combat_info:
		_logger.error("无法加载测试战斗数据")
		return

	_combat = _create_combat(_combat_info)
	_combat.initialize(_combat_info)

	_setup_scene()
	_setup_ui()
	_connect_combat_signals()

func _ready() -> void:
	_state_machine_manager.register_state_machine(
		"battle_state_machine",
		BattleStateMachine.new(),
		self,
		"init"
	)

## 准备下回合
func prepare_turn() -> void:
	_combat.prepare_turn()

func start_turn() -> void:
	_combat.start_turn()

func has_next_action_unit() -> bool:
	return _combat.get_next_actor() != null

func show_action_selection() -> void:
	game_form.show_action_menu(_combat.current_combat)

func execute_action(action_data: Dictionary) -> void:
	await _combat.execute_action(action_data)

func end_turn() -> void:
	await _combat.end_turn()

func is_max_turns_reached() -> bool:
	return _combat.is_max_turns_reached()

func is_battle_ended() -> bool:
	return _combat.check_battle_end().is_ended

func get_battle_result() -> String:
	return _combat.check_battle_end().outcome

func end_battle(result: String) -> void:
	_cleanup_battle()
	# 处理战斗结束后的场景转换
	back_to_explore()

func _setup_scene() -> void:
	pass

func _setup_ui() -> void:
	game_form.setup(_get_players())

func _connect_combat_signals() -> void:
	_combat.combat_started.connect(_on_combat_started)
	_combat.turn_started.connect(_on_turn_started)
	_combat.turn_ended.connect(_on_turn_ended)
	_combat.action_ready.connect(_on_action_ready)

func _cleanup_battle() -> void:
	_combat_info = null
	_combat = null

## 创建战斗
## TODO 增加战斗加载功能
## [param combat_model] 战斗数据
## [return] 战斗实例
func _create_combat(combat_model: CombatModel) -> Combat:
	var enemy_combats : Array[CombatComponent]
	var index := -1
	for enemy_model in combat_model.enemies:
		index += 1
		if not enemy_model: continue
		var enemy = _spawn_character(enemy_model)
		if not enemy: continue
		enemy.character_camp = CombatDefinition.COMBAT_CAMP_TYPE.ENEMY
		enemy_markers.get_child(index).add_child(enemy)
		# 这一步一定要在添加场景树之后，否则combat_component为空
		enemy_combats.append(enemy.combat_component)
		enemy.setup()
	var player_combats: Array[CombatComponent]
	for player : Character in _get_players():
		player_combats.append(player.combat_component)
	## 假设我们在开始时创建一场战斗，并将其作为当前存在的唯一战斗
	var combat : Combat = CombatSystem.create_combat(
		player_combats,
		enemy_combats,
		combat_model.max_turn_count,
		combat_model.is_auto,
		combat_model.is_real_time,
		%MarkerAction,
	)
	if combat.is_auto:
		game_form.handle_game_event("game_start")
	return combat

## 创建角色
## [param character_model] 角色数据
## [return] 角色实例
func _spawn_character(character_model: CharacterModel) -> Character:
	if not character_model: return null
	var character : Character = CHARACTER.instantiate()
	character.character_model = character_model
	return character

## 获取玩家角色
## [return] 玩家角色数组
func _get_players() -> Array[Character]:
	var players: Array[Character]
	for player in get_tree().get_nodes_in_group("Player"):
		players.append(player)
	return players

## 返回探索
func back_to_explore() -> void:
	_state_machine_manager.get_state_machine("gameplay").switch("explore")

func _on_combat_started() -> void:
	game_form.handle_game_event("combat_started")

func _on_turn_started() -> void:
	game_form.handle_game_event("turn_started")

func _on_turn_ended() -> void:
	game_form.handle_game_event("turn_ended")

func _on_action_ready(unit: CombatComponent) -> void:
	game_form.handle_game_event("action_ready", {"unit": unit})
