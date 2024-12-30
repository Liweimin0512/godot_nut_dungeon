extends Resource
class_name Combat

## 战斗信息

## 最大回合数，超过回合视为战斗失败
@export var max_turn_count: int = 99
## 战斗是否自动开始
@export var is_auto : bool = true
## 是否为实时战斗
@export var is_real_time: bool = true

## 当前回合计数
var _turn_count : int = 0
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

## 战斗开始，自动开始的战斗不会发射此信号
signal combat_started
## 回合开始
signal turn_started
## 回合结束
signal turn_ended
## 战斗胜利
signal combat_finished
## 战斗失败
signal combat_defeated
## 战斗结束
signal combat_ended

func _init(
		players: Array[CombatComponent] = [], 
		enemies : Array[CombatComponent] = [],
		p_max_turn_count: int = 99,
		p_is_auto : bool = true,
		p_is_real_time: bool = true,
		) -> void:
	player_combats = players
	enemy_combats = enemies
	max_turn_count = p_max_turn_count
	is_auto = p_is_auto
	is_real_time = p_is_real_time
	if is_auto:
		_combat_start()

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

## 手动开始战斗
func start_combat() -> void:
	_combat_start()

## 手动停止战斗
func stop() -> void:
	is_stop = true

## 战斗开始
func _combat_start() -> void:
	print("战斗开始！")
	combat_started.emit()
	for combat in combats:
		combat.died.connect(
			func() -> void:
				if combat.combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER:
					player_combats.erase(combat)
				elif combat.combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.ENEMY:
					enemy_combats.erase(combat)
				if player_combats.is_empty():
					_combat_defeat()
				elif enemy_combats.is_empty():
					_combat_finish()
		)
		combat.combat_start(self)
	await _turn_start()

## 回合开始
func _turn_start() -> void:
	if is_stop: return
	_turn_count += 1
	print(_turn_count, "回合开始===================")
	turn_started.emit(_turn_count)
	var cs := combats.duplicate()
	cs.shuffle()
	cs.sort_custom(
		func(a: CombatComponent, b: CombatComponent) -> bool:
			if not a or not b: return false
			return a.speed > b.speed
	)
	for combat in cs:
		if not is_instance_valid(combat): continue
		if not combat.is_alive: continue
		if is_real_time:
			await combat.turn_start()
		else:
			combat.turn_start()
	await _turn_end()

## 回合结束
func _turn_end() -> void:
	if is_stop: return
	if _turn_count >= max_turn_count:
		print("回合数耗尽")
		_combat_defeat()
	for combat in combats:
		if not is_instance_valid(combat): continue
		combat.turn_end()
	print("回合结束===================")
	turn_ended.emit()
	await _turn_start()

## 战斗胜利
func _combat_finish() -> void:
	print("===== 战斗胜利 =====, 回合数： ", _turn_count)
	combat_finished.emit()
	_combat_end()

## 战斗失败
func _combat_defeat() -> void:
	print("===== 战斗失败 =====, 回合数： ", _turn_count)
	combat_defeated.emit()
	_combat_end()
	
## 战斗结束
func _combat_end() -> void:
	for combat in combats:
		if not combat : continue
		combat.combat_end()
	is_stop = true
	combat_ended.emit()
