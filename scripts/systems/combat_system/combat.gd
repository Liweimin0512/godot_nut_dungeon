extends Resource
class_name Combat

## 战斗信息

## 最大回合数，超过回合视为战斗失败
@export var max_turn_count: int = 99
## 战斗是否自动开始
@export var is_auto : bool = true
## 是否为实时战斗
@export var is_real_time: bool = true
## 开始时间
@export var start_time: float = 0.5

## 当前回合计数
var _current_turn : int = 0
## 参战单位的CombatComponent数组
var combats : Array[CombatComponent]:
	get:
		return player_combats + enemy_combats
## 玩家战斗组件数组
var player_combats : Array[CombatComponent]
## 敌人战斗组件数组
var enemy_combats: Array[CombatComponent]
## 战斗是否停止
var is_stop := false
## 行动位置
var action_marker : Marker2D
## 当前行动顺序
var _action_order : Array[CombatComponent]
var current_combat : CombatComponent
var _config : CombatModel

## 战斗开始，自动开始的战斗不会发射此信号
signal combat_started
## 回合开始
signal turn_started(turn_count : int)
## 回合结束
signal turn_ended
## 战斗胜利
signal combat_finished
## 战斗失败
signal combat_defeated
## 战斗结束
signal combat_ended
## 行动准备
signal action_ready(unit: CombatComponent)

## 初始化
## [param conmbat_model] 战斗配置	
func initialize(conmbat_model: CombatModel) -> void:
	_config = conmbat_model
	_setup_combat_units()
	emit_signal("combat_started")

## 回合开始前
func prepare_turn() -> void:
	_current_turn += 1
	_calculate_action_order()
	combat_started.emit()

## 开始回合
func start_turn() -> void:
	turn_started.emit(_current_turn)
	_prepare_next_action()

func get_next_actor() -> CombatComponent:
	if _action_order.is_empty(): return null
	current_combat = _action_order.pop_front()
	return current_combat

func execute_action(action: Dictionary) -> void:
	if not current_combat: return
	await current_combat.execute_action(action)
	_prepare_next_action()

func end_turn() -> void:
	turn_ended.emit()

func is_max_turns_reached() -> bool:
	return _current_turn >= max_turn_count

func check_battle_end() -> Dictionary:
	var result : Dictionary = _calculate_combat_result()
	if result.is_ended:
		match result.outcome:
			"victory": combat_finished.emit()
			"defeat": combat_defeated.emit()
		combat_ended.emit()
	return result

## 获取随机敌方单位(的战斗组件）
func get_random_enemy(cha: CombatComponent) -> CombatComponent:
	var target : CombatComponent
	if cha.combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER:
		target = enemy_combats.pick_random()
	elif cha.combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.ENEMY:
		target = player_combats.pick_random()
	return target

## 获取所有敌人
func get_all_enemies(cha: CombatComponent) -> Array[CombatComponent]:
	if cha.combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER:
		return enemy_combats
	elif cha.combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.ENEMY:
		return player_combats
	return []

## 获取所有盟友
func get_all_allies(cha: CombatComponent) -> Array[CombatComponent]:
	if cha.combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER:
		return player_combats
	elif cha.combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.ENEMY:
		return enemy_combats
	return []

## 设置战斗单位
func _setup_combat_units() -> void:
	#TODO 设置战斗单位
	pass

## 设置行动顺序
func _calculate_action_order() -> Array[CombatComponent]:
	_action_order.clear()
	_action_order = combats.filter(
		func(combat: CombatComponent) -> bool: 
			if combat == null:
				return false
			return combat.can_action())
	_action_order.sort_custom(
		func(a: CombatComponent, b: CombatComponent) -> bool:
			return a.speed > b.speed
	)
	return _action_order

## 准备下一个行动
func _prepare_next_action() -> void:
	var next_actor := get_next_actor()
	if next_actor:
		action_ready.emit(next_actor)

## 计算战斗结果
func _calculate_combat_result() -> Dictionary:
	return {
		"is_ended": false,
		"outcome": "",
		"rewards": {}
	}
