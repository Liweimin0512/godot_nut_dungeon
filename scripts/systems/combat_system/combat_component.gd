extends Node
class_name CombatComponent

## 战斗组件，负责单个单位的战斗行为
## 包括：
## 1. 战斗状态管理
## 2. 行动执行
## 3. 伤害处理

## 当前战斗单位是否存活
var is_alive: bool:
	get:
		return ability_resource_component.get_resource_value("health") > 0
## 行动速度
var speed: float:
	get:
		return ability_attribute_component.get_attribute_value("speed")

# 依赖组件
@export var ability_component: AbilityComponent
@export var ability_resource_component: AbilityResourceComponent
@export var ability_attribute_component: AbilityAttributeComponent
## 战斗阵营
@export var _combat_camp: CombatDefinition.COMBAT_CAMP_TYPE = CombatDefinition.COMBAT_CAMP_TYPE.PLAYER
## 当前所在位置
@export_range(1, 4) var current_point: int = -1
## 当前行动
var current_action: CombatAction

signal hited
signal hurted
signal died

## 设置组件依赖
## [param p_camp] 战斗阵营
## [param p_point] 当前位置
## [param p_ability_component] 技能组件
## [param p_ability_attribute_component] 属性组件
## [param p_ability_resource_component] 资源组件
func setup(
			p_camp : CombatDefinition.COMBAT_CAMP_TYPE,
			p_point: int,
			p_ability_component: AbilityComponent = null,
			p_ability_attribute_component: AbilityAttributeComponent = null,
			p_ability_resource_component: AbilityResourceComponent = null,
		) -> void:
	_combat_camp = p_camp
	current_point = p_point
	if p_ability_component:
		ability_component = p_ability_component
	if p_ability_attribute_component:
		ability_attribute_component = p_ability_attribute_component
	if p_ability_resource_component:
		ability_resource_component = p_ability_resource_component

#region 战斗流程处理

## 战斗开始
func combat_start() -> void:
	await _notify_owner_turn_timing("_on_combat_start")
	ability_component.handle_game_event("on_combat_start")

## 回合开始
func turn_start() -> void:
	await _notify_owner_turn_timing("_on_turn_start")
	ability_component.handle_game_event("on_turn_start")

## 行动开始
## [param player_combats] 玩家控制角色
## [param enemy_combats] 敌人控制角色
func action_start(player_combats: Array[CombatComponent], enemy_combats: Array[CombatComponent]) -> void:
	# 选择合适的技能
	var ability := _selecte_ai_ability()
	# 选择合适的目标
	var targets := _selecte_ai_targets(ability, player_combats, enemy_combats)

	current_action = _create_combat_action(targets, ability)

	await _notify_owner_turn_timing("_on_action_start")

## 行动执行
func action_execute(player_combats: Array[CombatComponent], enemy_combats: Array[CombatComponent]) -> void:
	if not _can_action():
		return
	if not current_action:
		push_error("没有行动, 请检查是否调用了 action_start!")
		return

	var ability_context := {
		"caster": self,
		"targets": current_action.targets,
		"ability": current_action.ability,
		"tree": owner.get_tree(),
		"resource_component": ability_resource_component,
		"attribute_component": ability_attribute_component,
		"enemies": enemy_combats if _combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER else player_combats,
		"allies": player_combats if _combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER else enemy_combats,
	}
	await ability_component.try_cast_ability(current_action.ability, ability_context)
	await _notify_owner_turn_timing("_on_action_execute")

## 行动结束
func action_end() -> void:
	current_action = null
	ability_component.handle_game_event("on_action_end")
	await _notify_owner_turn_timing("_on_action_end")

## 回合结束
func turn_end() -> void:
	ability_component.handle_game_event("on_turn_end")
	await _notify_owner_turn_timing("_on_turn_end")

## 战斗结束
func combat_end() -> void:
	ability_component.handle_game_event("on_combat_end")
	await _notify_owner_turn_timing("_on_combat_end")

#endregion 战斗流程处理


## 创建战斗行动
## [param targets] 目标
## [param ability] 技能
## [param delay] 延时
## [return] 战斗行动
func _create_combat_action(targets: Array[CombatComponent], ability: TurnBasedSkillAbility = null, delay: float = 0.2) -> CombatAction:
	var target_nodes: Array[Node2D] = []
	for target in targets:
		target_nodes.append(target.get_parent())
	
	return CombatAction.new(
		get_parent(),  # 行动者节点
		target_nodes,  # 目标节点数组
		ability,       # 技能
		delay          # 延时
	)

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
		_die()
		
	await ability_component.handle_game_event("on_post_hurt", ability_context)

## 能否行动
func can_action() -> bool:
	return _can_action()

#region 内部方法

## 检查能否行动
func _can_action() -> bool:
	return is_alive and not owner.is_in_group("stunned")

## 死亡
func _die() -> void:
	ability_component.handle_game_event("on_die")
	died.emit()

## 获取可用技能
func _get_available_abilities() -> Array[Ability]:
	var available_abilities: Array[Ability] = []
	for ability in ability_component.get_abilities():
		if ability is TurnBasedSkillAbility and ability.can_use_at_position(current_point):
			available_abilities.append(ability)
	return available_abilities

## 选择AI技能
func _selecte_ai_ability() -> TurnBasedSkillAbility:
	if not CombatSystem.active_combat_manager.is_auto and _combat_camp != CombatDefinition.COMBAT_CAMP_TYPE.ENEMY:
		# 非自动战斗且不是敌方，不选择技能
		return
	# 获取可用技能
	var abilities := _get_available_abilities()
	# 随机选择一个技能
	var selected_ability : TurnBasedSkillAbility = abilities.pick_random()
	# 完成选择技能
	CombatSystem.action_ability_selected.push([self, selected_ability])
	return selected_ability

## 选择AI目标
func _selecte_ai_targets(ability : TurnBasedSkillAbility, 
		player_combats: Array[CombatComponent], 
		enemy_combats: Array[CombatComponent]) -> Array[CombatComponent]:
	# 获取可用的目标位置
	var available_positions := ability.get_available_positions(current_point)
	if available_positions.is_empty():
		push_error("选择的技能无法在当前位置使用")
		return []

	var selected_targets : Array[CombatComponent] = []
	# 处理自身目标
	if ability.target_range == TurnBasedSkillAbility.TARGET_RANGE.SELF:
		selected_targets = [self]
	else:
		# 获取目标阵营的单位
		var target_units : Array[CombatComponent] = _get_target_units(ability, player_combats, enemy_combats)
		if target_units.is_empty():
			# 没有目标单位，返回空数组
			push_error("没有目标单位，无法执行技能")
			return []
		# 根据技能类型选择目标
		selected_targets = _select_targets_by_range(ability, target_units, available_positions)
	CombatSystem.action_target_set.push([self, selected_targets])
	return selected_targets

## 获取目标阵营的有效单位
func _get_target_units(ability: TurnBasedSkillAbility, player_combats: Array[CombatComponent], enemy_combats: Array[CombatComponent]) -> Array[CombatComponent]:
	match ability.target_range:
		TurnBasedSkillAbility.TARGET_RANGE.SINGLE_ENEMY, TurnBasedSkillAbility.TARGET_RANGE.ALL_ENEMY:
			return enemy_combats if _combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER else player_combats
		TurnBasedSkillAbility.TARGET_RANGE.SINGLE_ALLY, TurnBasedSkillAbility.TARGET_RANGE.ALL_ALLY:
			return player_combats if _combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER else enemy_combats
	return []

## 根据技能范围选择目标
func _select_targets_by_range(ability: TurnBasedSkillAbility,
		target_units: Array[CombatComponent], available_positions: Array) -> Array[CombatComponent]:
	var selected_targets: Array[CombatComponent] = []
	
	match ability.target_range:
		TurnBasedSkillAbility.TARGET_RANGE.SINGLE_ENEMY:
			# 单体敌人技能：选择一个最优目标
			var target := _select_best_enemy_target(target_units, available_positions)
			if target:
				selected_targets.append(target)
				
		TurnBasedSkillAbility.TARGET_RANGE.SINGLE_ALLY:
			# 单体友军技能：选择一个最需要帮助的友军
			var target := _select_best_ally_target(target_units, available_positions)
			if target:
				selected_targets.append(target)
				
		TurnBasedSkillAbility.TARGET_RANGE.ALL_ENEMY, TurnBasedSkillAbility.TARGET_RANGE.ALL_ALLY:
			# 群体技能：选择所有在范围内的目标
			selected_targets = _select_area_targets(target_units, available_positions)
			
	return selected_targets

## 选择最优的敌方目标
func _select_best_enemy_target(targets: Array[CombatComponent], valid_positions: Array) -> CombatComponent:
	var scored_targets := []
	
	for target in targets:
		if not target.is_alive or not target.current_point in valid_positions:
			# 不满足目标条件的单位不计算, 目标死亡，位置不合适
			continue
		# 计算目标分数
		var score := _calculate_enemy_target_score(target)
		scored_targets.append({"target": target, "score": score})
	
	if scored_targets.is_empty():
		return null
		
	# 按分数排序
	scored_targets.sort_custom(func(a, b): return a.score > b.score)
	
	# 从前2个目标中随机选择一个（如果有的话）
	var top_n := mini(2, scored_targets.size())
	if top_n > 0:
		var random_index := randi() % top_n
		return scored_targets[random_index].target
	else:
		return null

## 选择最优的友军目标
func _select_best_ally_target(targets: Array[CombatComponent], valid_positions: Array) -> CombatComponent:
	var scored_targets := []
	
	for target in targets:
		if not target.is_alive or not target.current_point in valid_positions:
			continue
			
		var score := _calculate_ally_target_score(target)
		scored_targets.append({"target": target, "score": score})
	
	if scored_targets.is_empty():
		return null
		
	# 按分数排序
	scored_targets.sort_custom(func(a, b): return a.score > b.score)
	
	# 选择分数最高的目标
	return scored_targets[0].target

## 选择范围内的所有目标
func _select_area_targets(targets: Array[CombatComponent], valid_positions: Array) -> Array[CombatComponent]:
	var selected : Array[CombatComponent] = []
	for target in targets:
		if target.is_alive and target.current_point in valid_positions:
			selected.append(target)
	return selected

## 计算敌方目标分数
## 生命值低的目标优先级提高
## 嘲讽和标记的单位优先级提高
## 隐身单位和闪避状态的单位优先级降低
func _calculate_enemy_target_score(target: CombatComponent) -> float:
	var score := 100.0
	
	# 生命值低的目标优先级提高
	var health_percent := target.ability_resource_component.get_resource_percent("health")
	if health_percent < 0.3:
		score *= 2.0
	
	# 检查目标效果
	if target.ability_component.has_ability_tag("taunt"):
		score *= 3.0  # 嘲讽单位优先级最高
	if target.ability_component.has_ability_tag("marked"):
		score *= 2.0  # 被标记的单位优先级提高
	if target.ability_component.has_ability_tag("stealth"):
		score *= 0.5  # 隐身单位优先级降低
	if target.ability_component.has_ability_tag("dodge"):
		score *= 0.7  # 闪避状态的单位优先级降低
	
	# 添加随机因素
	score *= randf_range(0.9, 1.1)
	
	return score

## 计算友军目标分数
## 生命值低的友军优先级提高
## 保护者和被控制的单位优先级提高
## 中毒和流血的单位优先级提高
func _calculate_ally_target_score(target: CombatComponent) -> float:
	var score := 100.0
	
	# 生命值低的友军优先级提高
	var health_percent := target.ability_resource_component.get_resource_percent("health")
	if health_percent < 0.5:
		score *= (2.0 + (0.5 - health_percent) * 4.0)
	
	# 检查目标效果
	if target.ability_component.has_ability_tag("protect"):
		score *= 1.5  # 保护者优先级提高
	if target.ability_component.has_ability_tag("stun"):
		score *= 2.0  # 被控制的单位优先级提高
	if target.ability_component.has_ability_tag("poison"):
		score *= 1.8  # 中毒的单位优先级提高
	if target.ability_component.has_ability_tag("bleed"):
		score *= 1.8  # 流血的单位优先级提高
	
	# 添加随机因素（对友军目标的随机性较小）
	score *= randf_range(0.95, 1.05)
	
	return score

## 通知所有者回合时间点，并等待所有者执行完成
func _notify_owner_turn_timing(method_name: StringName) -> void:
	if get_parent().has_method(method_name):
		await get_parent().call(method_name)

#endregion

func _to_string() -> String:
	return "CombatComponent" + get_parent().to_string()
