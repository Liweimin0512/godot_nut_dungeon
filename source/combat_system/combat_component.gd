extends Node
class_name CombatComponent

## 战斗组件，管理战斗流程相关内容

## 依赖于技能系统组件
@onready var ability_component: AbilityComponent = %AbilityComponent
## 所属阵营
@export var camp : CombatDefinition.COMBAT_CAMP_TYPE = CombatDefinition.COMBAT_CAMP_TYPE.NONE
## 是否为存活单位
var is_alive : bool :
	get:
		return ability_component.get_resource_value("生命值") > 0
## 行动速度
var speed : float :
	get:
		return ability_component.get_attribute_value("速度")
## 当前战斗，为空则表示不是在战斗状态
var _current_combat: Combat
## 战斗组件所属角色，为了测试时候看着方便
var _cha_name : StringName : 
	get:
		return self.to_string()

signal hited(target: CombatComponent)
signal hurted(damage: int)
signal died
signal combat_started
signal combat_ended
signal turn_started
signal turn_ended

## 组件初始化
func initialization() -> void:
	pass

## 战斗开始
func combat_start(combat: Combat) -> void:
	print(self, "战斗开始！")
	_current_combat = combat	
	ability_component.on_combat_start()
	_update_ability_component_context()
	combat_started.emit()

## 回合开始
func turn_start() -> void:
	print(self, "====== 回合开始")
	if not _current_combat: 
		print(self, "当前非战斗状态！")
		return
	# 回合开始时更新技能的冷却计时
	ability_component.update_ability_cooldown()
	ability_component.update_buffs()
	ability_component.handle_game_event("on_turn_start")
	turn_started.emit()
	var ability: Ability = ability_component.get_available_abilities().pick_random()
	var targets := _get_ability_targets(ability)
	print("combat_component: {0} 尝试释放技能{1}".format([
		self, ability
	]))
	await ability_component.try_cast_ability(ability, {"targets" : targets})

## 回合结束
func turn_end() -> void:
	if not _current_combat: return
	print(self, "====== 回合结束")
	ability_component.handle_game_event("on_turn_end")
	turn_ended.emit()

## 战斗结束
func combat_end() -> void:
	print(self, " 战斗结束", "剩余血量: ", ability_component.get_resource_value("生命值"))
	_current_combat = null
	ability_component.handle_game_event("on_combat_end")
	for buff in ability_component.get_buffs():
		ability_component.remove_ability(buff)
	combat_ended.emit()

## 攻击
func hit(target: CombatComponent, attack: float) -> void:
	if not target: return
	var defense = target.ability_component.get_attribute_value("防御力")
	var damage : float = attack - defense
	print("combat_component: {0} 攻击： {1}, 攻击力{2}， 防御力{3}，实际造成伤害{4}".format([
		self, target, attack, defense, damage
	]))
	ability_component.handle_game_event("on_hit", {
		"targets" : [target],
		"attack" : attack,
		"defense" : defense,
		"damage" : damage
		})
	hited.emit(target)
	await target.hurt(self, damage)

## 受击
func hurt(damage_source: CombatComponent, damage: float) -> void:
	ability_component.handle_game_event("on_hurt", {
		"source" : damage_source,
		"damage" : damage
	})
	print("combat_component: {0} 受到来自 {1} 的伤害 {2}， 当前生命值{3}/{4}".format([
		self, damage_source, damage, 
		ability_component.get_resource_value("生命值"), 
		ability_component.get_attribute_value("生命值")
	]))
	var ok := ability_component.consume_resources("生命值", damage)
	hurted.emit(damage)
	if not ok:
		_die()

## 死亡
func _die() -> void:
	ability_component.handle_game_event("on_die")
	print("角色死亡：", self)
	died.emit()

## 获取随机敌人
func _get_random_enemy() -> CombatComponent:
	assert(_current_combat, "当前战斗不存在！不是战斗状态么？")
	return _current_combat.get_random_enemy(self)

## 更新技能组件上下文信息
func _update_ability_component_context() -> void:
	var context : Dictionary = ability_component.context
	if _current_combat:
		context["enemies"] = _current_combat.get_all_enemies(self)
		context["allies"] = _current_combat.get_all_allies(self)
	else:
		context["enemies"] = null
	ability_component.context = context

## 获取技能目标
func _get_ability_targets(ability : Ability) -> Array[CombatComponent]:
	# 主动释放的技能需要提供目标，在自动战斗中这需要通过战斗角色的AI来完成
	# 现阶段可以简化处理，直接获取随机目标
	var targets : Array[CombatComponent] = []  # 使用 := 进行类型推断和变量初始化
	var target_pool := []  # 统一的数组来存储目标池
	# 根据目标类型确定目标池
	if ability.target_type == "self":
		return [self]
	elif ability.target_type == "ally":
		target_pool = _current_combat.get_all_allies(self).duplicate()
	elif ability.target_type == "enemy":
		target_pool = _current_combat.get_all_enemies(self).duplicate()
	# 从目标池中随机选择目标
	for i in range(ability.target_amount):
		if target_pool.is_empty():
			break  # 如果目标池为空，退出循环
		var target : Node = target_pool.pick_random()
		targets.append(target)
		target_pool.erase(target)  # 从目标池中移除已选目标
	return targets

func _to_string() -> String:
	return owner.to_string()
