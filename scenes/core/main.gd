extends Node2D

const CHARACTER = preload("res://scenes/character/character.tscn")
## 需要预加载的effect配置文件列表
const EFFECT_CONFIGS := [
	"res://resources/data/abilities/effects/battle_cry_effect.json",
	"res://resources/data/abilities/effects/chain_lightning_effect.json",
	"res://resources/data/abilities/effects/counter_attack_buff.json",
	"res://resources/data/abilities/effects/fireball_effect.json",
	"res://resources/data/abilities/effects/heroic_strike_effect.json",
	"res://resources/data/abilities/effects/ignite_buff.json",
	"res://resources/data/abilities/effects/magic_missile_effect.json",
	"res://resources/data/abilities/effects/magic_shield_skill_effect.json",
	"res://resources/data/abilities/effects/mana_surge_buff.json",
	"res://resources/data/abilities/effects/unyielding_buff.json"
]

# @onready var rich_text_label: RichTextLabel = %RichTextLabel
# @onready var player_character: Character = $PlayerCharacter
@onready var enemy_markers: Node2D = $EnemyMarkers
@onready var marker_action: Marker2D = %MarkerAction
@onready var game_form: GameForm = $UILayer/GameForm

@export var combat_test : CombatModel

func _ready() -> void:
	JsonLoader.batch_load_json(EFFECT_CONFIGS, _on_load_json_complete)

func _on_load_json_complete(_results: Dictionary) -> void:
	var combat : Combat = _create_combat(combat_test.duplicate())
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
			func(ability: Ability) -> void:
				# rich_text_label.text += "{0} 释放 {1} 技能！\n".format([c_combat, ability])
				game_form.handle_game_event("combat_ability_cast", {"owner": c_combat.owner, "ability": ability})
		)

## 创建战斗
func _create_combat(combat_model: CombatModel) -> Combat:
	var enemy_combats : Array[CombatComponent]
	var index := 0
	for enemy_model in combat_model.enemies:
		var enemy = _spawn_character(enemy_model)
		enemy.character_camp = CombatDefinition.COMBAT_CAMP_TYPE.ENEMY
		enemy_markers.get_child(index).add_child(enemy)
		# 这一步一定要在添加场景树之后，否则combat_component为空
		enemy_combats.append(enemy.combat_component)
		index += 1
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
	var character : Character = CHARACTER.instantiate()
	character.character_model = character_model
	return character

## 获取玩家角色
func _get_players() -> Array[Character]:
	var players: Array[Character]
	for player in get_tree().get_nodes_in_group("Player"):
		players.append(player)
	return players
