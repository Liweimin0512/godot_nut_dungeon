extends Node2D

const CHARACTER = preload("res://source/character.tscn")

@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var player_character: Character = $PlayerCharacter
@onready var enemy_markers: Node2D = $EnemyMarkers

@export var combat_test : CombatModel

func _ready() -> void:
	var combat : Combat = _create_combat(combat_test.duplicate())
	# 因为combat是自动执行的，所以不会发出这个信号！
	combat.combat_started.connect(
		func() -> void:
			rich_text_label.text += "战斗开始\n"
	)
	combat.turn_started.connect(
		func(turn_count: int) -> void:
			rich_text_label.text += "{0}回合开始\n".format([
				turn_count,
			])
	)
	combat.turn_ended.connect(
		func() -> void:
			rich_text_label.text += "回合结束\n"
	)
	combat.combat_finished.connect(
		func() -> void:
			rich_text_label.text += "战斗胜利\n"
	)
	combat.combat_defeated.connect(
		func() -> void:
			rich_text_label.text += "战斗失败\n"
	)
	for c_combat in combat.combats:
		c_combat.hited.connect(
			func(target: CombatComponent) -> void:
				rich_text_label.text += "{0} 攻击 {1}\n".format([
					c_combat.owner, target.owner
				])
		)
		c_combat.hurted.connect(
			func(damage: int) -> void:
				rich_text_label.text += "{0} 受到{1}点伤害！\n".format([
					c_combat.owner, damage
				])
		)
		c_combat.ability_component.ability_cast_finished.connect(
			func(ability: Ability) -> void:
				rich_text_label.text += "{0} 释放 {1} 技能！\n".format([c_combat, ability])
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
	## 假设我们在开始时创建一场战斗，并将其作为当前存在的唯一战斗
	var combat : Combat = CombatSystem.create_combat(
		[player_character.combat_component],
		enemy_combats,
		combat_model.max_turn_count,
		combat_model.is_auto,
		combat_model.is_real_time
		#%MarkerAction,
	)
	if combat.is_auto:
		rich_text_label.text += "战斗开始\n"
	return combat

## 创建角色
func _spawn_character(character_model: CharacterModel) -> Character:
	var character : Character = CHARACTER.instantiate()
	character.character_model = character_model
	return character
