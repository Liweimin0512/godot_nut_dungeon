extends LogicComponent
class_name CombatComponent

## 战斗组件，负责单个单位的战斗行为
## 包括：
## 1. 战斗状态管理
## 2. 行动执行
## 3. 伤害处理
## 4. 动画播放

## 战斗配置
@export var combat_camp: CombatDefinition.COMBAT_CAMP_TYPE = CombatDefinition.COMBAT_CAMP_TYPE.PLAYER
@export var return_action_time: float = 0.2

## 战斗属性
var is_alive: bool:
	get:
		return ability_resource_component.get_resource_value("生命值") > 0

var speed: float:
	get:
		return ability_attribute_component.get_attribute_value("速度")

## 战斗状态
var _current_combat: CombatManager
var _is_actioning: bool = false

## 依赖组件
@export var ability_component: AbilityComponent
@export var ability_resource_component: AbilityResourceComponent
@export var ability_attribute_component: AbilityAttributeComponent

## 战斗信号
signal died
signal combat_started
signal combat_ended
signal turn_prepared
signal turn_started
signal turn_ended
signal hited(target: CombatComponent)
signal hurted(damage: int)

func _on_data_updated(data: Dictionary) -> void:
	combat_camp = data.get("combat_camp", CombatDefinition.COMBAT_CAMP_TYPE.PLAYER)
	ability_component = data.get("ability_component", null)
	ability_resource_component = data.get("ability_resource_component", null)
	ability_attribute_component = data.get("ability_attribute_component", null)

## 战斗开始
func combat_start(combat: CombatManager) -> void:
	_current_combat = combat
	ability_component.handle_game_event("on_combat_start")
	combat_started.emit()

## 回合开始前
func turn_prepare() -> void:
	ability_component.handle_game_event("on_pre_turn_start")
	turn_prepared.emit()

## 回合开始
func turn_start() -> void:
	if not _current_combat:
		return
	turn_started.emit()
	ability_component.handle_game_event("on_turn_start")

## 执行行动
func action() -> void:
	if not _can_action():
		return
		
	var available_abilities := _get_available_abilities()
	if available_abilities.is_empty():
		return
		
	var ability: Ability = available_abilities.pick_random()
	if not ability:
		return
		
	var target := _get_ability_target(ability)
	if not target:
		return
		
	var ability_context := {
		"caster": self,
		"target": target,
		"ability": ability,
		"tree": owner.get_tree(),
		"casting_point": _current_combat.action_marker.global_position if _current_combat else Vector2.ZERO,
		"resource_component": ability_resource_component,
		"attribute_component": ability_attribute_component
	}
	
	_is_actioning = true
	await _pre_action(ability_context)
	var ok := await ability_component.try_cast_ability(ability, ability_context)
	if not ok:
		_print("释放技能失败")
	await _post_action(ability_context)
	_is_actioning = false

## 回合结束
func turn_end() -> void:
	if not _current_combat:
		return
	await ability_component.handle_game_event("on_turn_end")
	turn_ended.emit()

## 战斗结束
func combat_end() -> void:
	_current_combat = null
	await ability_component.handle_game_event("on_combat_end")
	combat_ended.emit()

## 攻击
func hit(damage: AbilityDamage) -> void:
	var target := damage.defender
	if not target:
		return
		
	await ability_component.handle_game_event("on_pre_hit", {"damage": damage})
	await target.hurt(self, damage)
	hited.emit(target)
	await ability_component.handle_game_event("on_post_hit", {"damage": damage})

## 受击
func hurt(damage_source: CombatComponent, damage: AbilityDamage) -> void:
	if not damage_source:
		return
		
	var ability_context := {
		"damage": damage,
		"caster": self,
		"target": damage.attacker
	}
	
	await ability_component.handle_game_event("on_pre_hurt", ability_context)
	ability_resource_component.apply_damage(damage)
	hurted.emit(damage.damage_value)
	
	if not is_alive:
		if _is_actioning:
			await _move_from_action()
		_die()
		
	await ability_component.handle_game_event("on_post_hurt", ability_context)

## 能否行动
func can_action() -> bool:
	return _can_action()

## 内部方法
func _can_action() -> bool:
	return is_alive and not _is_actioning and not owner.is_in_group("stunned")

func _get_ability_target(ability: Ability) -> CombatComponent:
	if not _current_combat or ability.target_type.is_empty():
		return null
		
	var valid_targets : Array[CombatComponent] = _current_combat.get_valid_targets(self, ability.target_type)
	if valid_targets.is_empty():
		return null
		
	return valid_targets.pick_random()

func _get_available_abilities() -> Array[Ability]:
	var available_abilities: Array[Ability] = []
	for ability in ability_component.get_abilities():
		if ability is SkillAbility and ability.is_available:
			available_abilities.append(ability)
	return available_abilities

func _pre_action(ability_context: Dictionary) -> void:
	owner.z_index = 10
	ability_component.handle_game_event("on_action_started", ability_context)
	await owner.get_tree().create_timer(0.2).timeout

func _post_action(ability_context: Dictionary) -> void:
	owner.z_index = 0
	ability_component.handle_game_event("on_action_completed", ability_context)
	await _move_from_action()

func _move_from_action() -> void:
	var tween := owner.get_tree().create_tween()
	# tween.tween_property(owner, "global_position", _combat_position, return_action_time)
	await tween.finished

func _die() -> void:
	ability_component.handle_game_event("on_die")
	died.emit()

func _print(s: String) -> void:
	var color = "#FFFF00"
	print_rich("[color={0}] [COMBAT_COMPONENT] {1}[/color]".format([color, s]))
