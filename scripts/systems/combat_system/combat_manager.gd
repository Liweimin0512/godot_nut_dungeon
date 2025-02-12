extends Resource
class_name CombatManager

## 战斗管理器，负责管理整个战斗流程
## 包括：
## 1. 战斗单位的注册和管理
## 2. 回合制战斗流程的控制
## 3. 目标选择系统
## 4. 战斗行动的执行

# 战斗配置
## 最大回合数
var max_turn_count: int = 99
## 是否自动开始
var is_auto: bool = true
## 是否实时
var is_real_time: bool = false

# 战斗状态
## 当前回合数
var current_turn: int = 0
## 是否战斗中
var is_combat_active: bool = false

# 战斗单位
## 玩家单位
var player_combats: Array[CombatComponent] = []
## 敌人单位
var enemy_combats: Array[CombatComponent] = []
## 角色行动顺序
var action_order: Array[CombatComponent] = []
var prepared_units : int = 0

var _event_bus : CoreSystem.EventBus:
	get:
		return CoreSystem.event_bus

## 战斗相关信号
signal combat_started
signal combat_ended
signal turn_prepared
signal turn_prepare_ended
signal turn_started(turn_count: int)
signal turn_ended
signal combat_finished
signal combat_defeated
signal action_ready(unit: CombatComponent)

signal skill_selected(unit: CombatComponent, skill: TurnBasedSkillAbility)
signal target_selected(unit: CombatComponent, targets: Array[CombatComponent])

## 初始化战斗
func initialize(combat_info: CombatModel) -> void:
	_event_bus.subscribe("character_turn_prepare_end", _on_character_turn_prepare_end)
	_event_bus.subscribe("character_target_selected", _on_character_target_selected)
	max_turn_count = combat_info.max_turn_count
	is_auto = combat_info.is_auto
	is_real_time = combat_info.is_real_time
	
	# 初始化战斗状态
	current_turn = 0
	is_combat_active = false

## 开始战斗
func start_combat() -> void:
	if is_combat_active:
		return
	
	is_combat_active = true
	combat_started.emit()

	# 开始第一个回合
	await start_turn()

## 结束战斗
func end_combat() -> void:
	if not is_combat_active:
		return
	
	is_combat_active = false
	
	# 通知所有单位战斗结束
	for unit in player_combats + enemy_combats:
		unit.combat_end()
	
	combat_ended.emit()

## 准备回合
func turn_prepare() -> void:
	current_turn += 1
	if current_turn > max_turn_count:
		end_combat()
		return
	
	action_order = _sort_units_by_speed()
	for unit : CombatComponent in action_order:
		unit.turn_prepare()
	turn_prepared.emit()

## 开始新回合
func start_turn() -> void:
	if not is_combat_active:
		return

	turn_started.emit(current_turn)
	
	# 开始行动循环
	var unit : CombatComponent = action_order.pop_front()
	unit.turn_start()


## 目标选择
func action_select() -> void:
	
	if not current_acting_unit or not current_acting_unit.is_alive:
		# switch_to("turn_end")
		return
	
	# 通知UI有单位准备行动
	action_ready.emit(current_acting_unit)
	
	# 如果是敌方单位，执行AI行动选择
	if current_acting_unit.combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.ENEMY:
		select_ai_action(current_acting_unit)
		# switch_to("action_execute")
	# 如果是自动战斗，也执行AI行动选择
	elif is_auto:
		select_ai_action(current_acting_unit)
		# switch_to("action_execute")
	# 否则等待玩家选择行动
	else:
		# 状态机会保持在当前状态，等待外部消息触发状态切换
		pass

## 结束回合
func end_turn() -> void:
	if not is_combat_active:
		return
	
	# 通知所有单位回合结束
	for unit in player_combats + enemy_combats:
		unit.turn_end()
	
	turn_ended.emit()
	
	# 检查战斗状态
	if _check_combat_end():
		end_combat()
	else:
		# 开始新回合
		await start_turn()

## 执行行动
func execute_action(unit: CombatComponent, action_data: Dictionary) -> void:
	if not is_combat_active or current_acting_unit != unit:
		return
	
	await unit.execute_action(action_data)

## 获取目标
func get_valid_targets(unit: CombatComponent, target_type: String) -> Array[CombatComponent]:
	var targets: Array[CombatComponent] = []
	
	match target_type:
		"self":
			targets.append(unit)
		"ally":
			targets = get_all_allies(unit)
		"enemy":
			targets = get_all_enemies(unit)
		"all":
			targets = get_all_allies(unit) + get_all_enemies(unit)
	
	# 过滤掉死亡单位
	targets = targets.filter(func(target): return target.is_alive)
	
	return targets

## 获取所有敌人
func get_all_enemies(unit: CombatComponent) -> Array[CombatComponent]:
	if unit.combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER:
		return enemy_combats
	return player_combats

## 获取所有盟友
func get_all_allies(unit: CombatComponent) -> Array[CombatComponent]:
	if unit.combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER:
		return player_combats
	return enemy_combats

func get_available_skills(unit: CombatComponent) -> Array[TurnBasedSkillAbility]:
	var position = get_unit_position(unit)
	var skills = []
	for skill in unit._ability_component.get_abilities():
		if not skill is TurnBasedSkillAbility:
			continue
		if skill.can_use_at_position(position):
			skills.append(skill)
	return skills























## 角色行动顺序排序
func _sort_units_by_speed() -> Array[CombatComponent]:
	var order : Array[CombatComponent] = player_combats + enemy_combats
	order.shuffle()
	order.sort_custom(func(a, b): return a.speed > b.speed)
	return order

func _get_active_units() -> Array[CombatComponent]:
	var units : Array[CombatComponent] = []
	for unit in player_combats + enemy_combats:
		if unit.is_alive and unit.can_action():
			units.append(unit)
	return units

func _check_combat_end() -> bool:
	var players_alive = player_combats.any(func(unit): return unit.is_alive)
	var enemies_alive = enemy_combats.any(func(unit): return unit.is_alive)
	
	if not players_alive:
		combat_defeated.emit()
		return true
	
	if not enemies_alive:
		combat_finished.emit()
		return true
	
	return false

func _execute_ai_action(unit: CombatComponent) -> void:
	# 选择AI行动
	var action_data = select_ai_action(unit)
	if action_data:
		await execute_action(unit, action_data)

func _wait_for_player_action(_unit: CombatComponent) -> void:
	# TODO: 实现等待玩家输入的逻辑
	pass

func _on_unit_died(_unit: CombatComponent) -> void:
	# 检查战斗是否结束
	if _check_combat_end():
		end_combat()

## AI行动选择
func select_ai_action(unit: CombatComponent) -> Dictionary:
	if not unit or not unit.is_alive:
		return {}
	
	# 获取可用的技能列表
	var available_abilities = unit.get_available_abilities()
	if available_abilities.is_empty():
		return {}
	
	# 评估每个技能的优先级
	var best_action = _evaluate_abilities(unit, available_abilities)
	if not best_action:
		return {}
	
	# 设置当前选择的行动
	return best_action

## 评估技能优先级
func _evaluate_abilities(unit: CombatComponent, abilities: Array[Ability]) -> Dictionary:
	var scored_actions: Array = []
	
	for ability in abilities:
		var valid_targets = get_valid_targets(unit, ability.target_type)
		if valid_targets.is_empty():
			continue
		
		for target in valid_targets:
			var score = _score_ability_target(unit, ability, target)
			scored_actions.append({
				"ability": ability,
				"target": target,
				"score": score
			})
	
	# 按分数排序
	scored_actions.sort_custom(func(a, b): return a.score > b.score)
	
	# 返回最高分的行动
	if not scored_actions.is_empty():
		var action = scored_actions[0]
		return {
			"ability": action.ability,
			"target": action.target
		}
	
	return {}

## 计算技能-目标组合的分数
func _score_ability_target(unit: CombatComponent, ability: Ability, target: CombatComponent) -> float:
	var score: float = 0.0
	
	# 基础分数
	score += ability.base_score if "base_score" in ability else 1.0
	
	# 目标生命值百分比
	var target_hp_percent = target.get_health_percent()
	
	# 如果是治疗技能
	if ability.is_heal:
		# 生命值越低，分数越高
		score += (1.0 - target_hp_percent) * 2.0
		# 优先治疗玩家单位
		if target.combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER:
			score += 0.5
	# 如果是攻击技能
	else:
		# 生命值越低，分数越高（优先击杀濒死目标）
		score += (1.0 - target_hp_percent) * 1.5
		# 优先攻击玩家单位
		if target.combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER:
			score += 0.5
	
	# 考虑目标的状态效果
	if target.has_status_effect("mark"):
		score += 1.0
	if target.has_status_effect("stun"):
		score -= 0.5  # 降低攻击被眩晕目标的优先级
	
	# 考虑施法者的状态
	if unit.has_status_effect("buff"):
		score += 0.5
	
	# 随机因素（避免AI行为过于机械）
	score += randf_range(-0.2, 0.2)
	
	return score

func _on_character_turn_prepare_end(_unit: CombatComponent) -> void:
	var units = player_combats + enemy_combats
	prepared_units += 1
	if prepared_units >= units.size():
		prepared_units = 0
		turn_prepare_ended.emit()

func _on_character_target_selected(_unit: CombatComponent, _target: CombatComponent) -> void:
	# 选中目标后执行方法
	pass
