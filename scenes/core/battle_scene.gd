extends Node2D

const CHARACTER = preload("res://scenes/character/character.tscn")

@onready var enemy_markers: Node2D = $EnemyMarkers
@onready var marker_action: Marker2D = %MarkerAction
@onready var game_form: GameForm = $UILayer/GameForm

@export var combat_test_id : StringName

var _state_machine_manager: CoreSystem.StateMachineManager = CoreSystem.state_machine_manager
var _logger: CoreSystem.Logger = CoreSystem.logger

var _combat_info: CombatModel = null

# 初始化状态，在ready之前执行
func init_state(data: Dictionary) -> void:
	_combat_info = data.get("combat_info", null)

func _ready() -> void:
	_state_machine_manager.register_state_machine(
		"gameplay",
		BattleStateMachine.new(),
		self,
		"explore"  # 默认从探索状态开始
	)
	EffectNodeFactory.register_node_type("move_to_casting_position", "res://scripts/systems/ability/ability_effect_node/move_to_casting_position_effect.gd")
	var combat_model : CombatModel = DataManager.get_data_model("combat", "test")
	var combat : Combat = _create_combat(combat_model)
	for player in _get_players():
		var player_model : CharacterModel = DataManager.get_data_model("character", "crystal_mauler")
		player.setup(player_model)
	game_form.setup(_get_players())
	# 因为combat是自动执行的，所以不会发出这个信号！
	combat.combat_started.connect(
		func() -> void:
			# rich_text_label.text += "战斗开始\n"
			game_form.handle_game_event("game_start")
	)
	combat.turn_started.connect(
		func(turn_count: int) -> void:
			# rich_text_label.text += "{0}回合开始\n".format([turn_count,])
			game_form.handle_game_event("turn_start", {"turn_count": turn_count}
			)
	)
	combat.turn_ended.connect(
		func() -> void:
			# rich_text_label.text += "回合结束\n"
			game_form.handle_game_event("turn_end")
	)
	combat.combat_finished.connect(
		func() -> void:
			# rich_text_label.text += "战斗胜利\n"
			game_form.handle_game_event("combat_win")
	)
	combat.combat_defeated.connect(
		func() -> void:
			# rich_text_label.text += "战斗失败\n"
			game_form.handle_game_event("combat_defeated")
	)
	for c_combat in combat.combats:
		c_combat.hited.connect(
			func(target: CombatComponent) -> void:
				# rich_text_label.text += "{0} 攻击 {1}\n".format([c_combat.owner, target.owner])
				game_form.handle_game_event("combat_hit", {"owner": c_combat.owner, "target": target.owner})
		)
		c_combat.hurted.connect(
			func(damage: int) -> void:
				# rich_text_label.text += "{0} 受到{1}点伤害！\n".format([c_combat.owner, damage])
				game_form.handle_game_event("combat_hurt", {"owner": c_combat.owner, "damage": damage})
		)
		c_combat.ability_component.ability_cast_finished.connect(
			func(ability: Ability, _context: Dictionary) -> void:
				# rich_text_label.text += "{0} 释放 {1} 技能！\n".format([c_combat, ability])
				game_form.handle_game_event("combat_ability_cast", {"owner": c_combat.owner, "ability": ability})
		)


## 创建战斗
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
func _spawn_character(character_model: CharacterModel) -> Character:
	if not character_model: return null
	var character : Character = CHARACTER.instantiate()
	character.character_model = character_model
	return character

## 获取玩家角色
func _get_players() -> Array[Character]:
	var players: Array[Character]
	for player in get_tree().get_nodes_in_group("Player"):
		players.append(player)
	return players

## 进入战斗
func enter_battle(battle_config: Dictionary = {}) -> void:
	_state_machine_manager.get_state_machine("gameplay").switch_to("battle", battle_config)

## 开始对话
func start_dialogue(dialogue_config: Dictionary = {}) -> void:
	_state_machine_manager.get_state_machine("gameplay").switch_to("dialogue", dialogue_config)

## 打开菜单
func open_menu() -> void:
	_state_machine_manager.get_state_machine("gameplay").switch_to("menu")

## 返回探索
func back_to_explore() -> void:
	_state_machine_manager.get_state_machine("gameplay").switch_to("explore")
