extends Node
class_name CombatComponent

## 战斗组件，管理战斗流程相关内容

## 所属阵营
@export var combat_camp : CombatDefinition.COMBAT_CAMP_TYPE = CombatDefinition.COMBAT_CAMP_TYPE.NONE
## 近身施法位置偏移
@export var melee_action_offset: Vector2 = Vector2(20, 0)
## 施法位置Marker2D字典
@export var cast_position_dict : Dictionary[String, Marker2D] = {}
## 返回行动耗时
@export var return_action_time : float = 0.2
## 是否为存活单位
var is_alive : bool = true:
	get:
		return ability_resource_component.get_resource_value("生命值") > 0
## 行动速度
var speed : float :
	get:
		return ability_attribute_component.get_attribute_value("速度")

## 当前战斗，为空则表示不是在战斗状态
var _current_combat: Combat
## 战斗组件所属角色，为了测试时候看着方便
var _combat_owner_name : StringName : 
	get:
		return self.to_string()
## 战斗位置
var _combat_position : Vector2 = Vector2.ZERO
## 当前是否为正在行动状态
var _is_actioning : bool = false

## 依赖于技能系统组件
@export var ability_component: AbilityComponent
@export var ability_resource_component: AbilityResourceComponent
@export var ability_attribute_component: AbilityAttributeComponent

signal hited(target: CombatComponent)
signal hurted(damage: int)
signal died
signal combat_started
signal combat_ended
signal turn_started
signal turn_ended

## 组件初始化
func initialization(camp: CombatDefinition.COMBAT_CAMP_TYPE) -> void:
	combat_camp = camp
	_print("combat_component: {0} 初始化".format([_combat_owner_name]))
	_combat_position = owner.global_position

## 战斗开始
func combat_start(combat: Combat) -> void:
	_print("战斗开始！")
	_current_combat = combat
	ability_component.handle_game_event("on_combat_start")
	combat_started.emit()

## 回合开始前
func pre_turn_start() -> void:
	# ability_component.update_ability_cooldown()
	# ability_component.update_buffs()
	ability_component.handle_game_event("on_pre_turn_start")

## 回合开始
func turn_start() -> void:
	_print("回合开始！")
	if not _current_combat: 
		_print("当前非战斗状态！")
		return
	turn_started.emit()
	# 回合开始时更新技能的冷却计时
	ability_component.handle_game_event("on_turn_start")
	await action()

## 行动
func action() -> void:
	if not _can_action():
		_print("当前处于眩晕状态，无法动！跳过本回合！")
		return
	_print("combat_component: {0} 行动".format([self]))
	var available_abilities := _get_available_abilities()
	if available_abilities.is_empty(): return
	var ability: Ability = available_abilities.pick_random()
	if not ability:
		_print("combat_component: 无可用技能，跳过{0}的回合".format([self]))
	else:
		#await get_tree().create_timer(action_time).timeout
		var target := _get_ability_target(ability)
		_print("combat_component: {0} 尝试释放技能{1}".format([
			self, ability
		]))
		var ability_context : Dictionary = {
			"caster" : self,
			"enemies" : _current_combat.get_all_enemies(self),
			"allies" : _current_combat.get_all_allies(self),
			"target" : target,
			"ability" : ability,
			"tree": get_tree(),
			"casting_point": _current_combat.action_marker.global_position,
			"resource_component": ability_resource_component,
			"attribute_component": ability_attribute_component
		}
		_is_actioning = true
		await _pre_action(ability_context)
		var ok := await ability_component.try_cast_ability(ability, ability_context)
		if not ok:
			_print("combat_component: {0} 释放技能失败".format([self]))
		await _post_action(ability_context)
		_is_actioning = false
	
## 回合结束
func turn_end() -> void:
	if not _current_combat: return
	_print("====== 回合结束")
	await ability_component.handle_game_event("on_turn_end", {})
	turn_ended.emit()

## 战斗结束
func combat_end() -> void:
	_print("===== 战斗结束! 剩余血量: {0}".format([ability_resource_component.get_resource_value("生命值")]))
	_current_combat = null
	await ability_component.handle_game_event("on_combat_end")
	for ability in ability_component.get_abilities():
		if ability is BuffAbility:
			ability_component.remove_ability(ability, {})
	combat_ended.emit()

## 攻击
func hit(damage: AbilityDamage) -> void:
	var target : CombatComponent = damage.defender
	if not target: return
	_print("combat_component: {0} 攻击： {1}, damage info:{2}".format([
		self, target, damage.damage_value
	]))
	await ability_component.handle_game_event("on_pre_hit", {"damage" : damage})
	await target.hurt(self, damage)
	hited.emit(target)
	await ability_component.handle_game_event("on_post_hit", {"damage" : damage})

## 受击
func hurt(damage_source: CombatComponent, damage: AbilityDamage) -> void:
	if not damage_source: return
	var ability_context : Dictionary = {
		"damage": damage, "caster": self , "target": damage.attacker
	}
	await ability_component.handle_game_event("on_pre_hurt", ability_context)
	_print("combat_component: {0} 受到来自 {1} 的伤害 {2} 点， 当前生命值{3}/{4}".format([
		self, damage_source, damage.damage_value, 
		ability_resource_component.get_resource_value("生命值"), 
		ability_attribute_component.get_attribute_value("生命值")
	]))
	ability_resource_component.apply_damage(damage)
	hurted.emit(damage.damage_value)
	await get_tree().create_timer(0.5).timeout
	await ability_component.handle_game_event("on_post_hurt", ability_context)
	var health_value : float = ability_resource_component.get_resource_value("生命值")
	if health_value <= 0:
		if _is_actioning:
			await _move_from_action()
		_die()

func can_action() -> bool:
	return _can_action()

## 获取施法位置
func get_cast_position(position_type: String) -> Vector2:
	var marker : Marker2D = cast_position_dict.get(position_type)
	if marker:
		var point : Vector2
		if combat_camp == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER:
			point = marker.position
		else:
			point = marker.position * Vector2(-1, 1)
		return point
	return Vector2.ZERO

## 播放动画
func play_animation(animation_name : StringName, blend_time: float = 0.0, custom_speed: float = 1.0) -> void:
	%AnimationPlayer.play(animation_name, blend_time, custom_speed)

## 行动前
func _pre_action(ability_context: Dictionary) -> void:
	owner.z_index = 10
	ability_component.handle_game_event("on_action_started", ability_context)
	await get_tree().create_timer(0.2).timeout

## 行动后
func _post_action(ability_context: Dictionary) -> void:
	owner.z_index = 0
	ability_component.handle_game_event("on_action_completed", ability_context)
	await _move_from_action()

## 能否行动？
func _can_action() -> bool:
	return not is_in_group("stunned")

## 死亡
func _die() -> void:
	ability_component.handle_game_event("on_die")
	_print("角色死亡!")
	died.emit()

## 获取技能目标
func _get_ability_target(ability : Ability) -> CombatComponent:
	# 主动释放的技能需要提供目标，在自动战斗中这需要通过战斗角色的AI来完成
	# 现阶段可以简化处理，直接获取随机目标
	var target_pool := []  # 统一的数组来存储目标池
	if ability.target_type.is_empty(): return null
	# 根据目标类型确定目标池
	if ability.target_type == "self":
		# 以自身为目标的技能不需要提供
		return self
	elif ability.target_type == "ally":
		target_pool = _current_combat.get_all_allies(self).duplicate()
	elif ability.target_type == "enemy":
		target_pool = _current_combat.get_all_enemies(self).duplicate()
	var target : Node = target_pool.pick_random()
	return target

## 移动回原位置
func _move_from_action() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(owner, "global_position", _combat_position, return_action_time)
	await tween.finished

## 获取技能上下文
func _get_ability_context() -> Dictionary:
	return {"caster" : self}

## 获取可用主动技能
func _get_available_abilities() -> Array[Ability]:
	var available_abilities : Array[Ability] = []
	for ability in ability_component.get_abilities():
		if ability is SkillAbility and ability.is_available:
			available_abilities.append(ability as SkillAbility)
	return available_abilities

## 判断技能是否可用
func _is_ability_available(ability: Ability) -> bool:
	if not ability is SkillAbility: return false
	## 这个方法用来筛选哪些可用的主动技能
	return not ability.is_cooldown and not ability.is_auto_cast and ability.can_cast

func _print(s : String) -> void:
	var color = "#FFFF00"
	print_rich("[color={0}] [COMBAT_COMPONENT] {2} : {1}[/color]".format([color, s, self.to_string()]))

func _on_ability_component_ability_trigger_success(ability: Ability) -> void:
	_print("触发了技能：{0}".format([ability]))

func _on_ability_component_ability_trigger_failed(ability: Ability) -> void:
	_print("触发技能失败：{0}".format([ability]))

func _to_string() -> String:
	return owner.to_string()
