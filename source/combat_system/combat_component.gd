extends Node
class_name CombatComponent

## 战斗组件，管理战斗流程相关内容

## 依赖于技能系统组件
@onready var ability_component: AbilityComponent = %AbilityComponent
## 所属阵营
@export var camp : CombatDefinition.COMBAT_CAMP_TYPE = CombatDefinition.COMBAT_CAMP_TYPE.NONE
## 是否为存货单位
var is_alive : bool :
	get:
		return ability_component.current_health > 0
## 行动速度
var speed : float :
	get:
		return ability_component.speed
## 当前战斗，为空则表示不是在战斗状态
var _current_combat: Combat

signal hited(target: CombatComponent)
signal hurted(damage: int)
signal died
signal combat_started
signal combat_ended

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
	ability_component.on_turn_start()
	var ability: Ability = ability_component.get_available_abilities().pick_random()
	await ability_component.try_cast_ability(ability)
	#var target := _current_combat.get_random_enemy(self)
	#if _current_combat.is_real_time:
		#await get_tree().create_timer(0.5).timeout
	#if not target: return
	#await hit(target)

## 回合结束
func turn_end() -> void:
	if not _current_combat: return
	print(self, "====== 回合结束")
	ability_component.on_turn_end()

## 战斗结束
func combat_end() -> void:
	print(self, " 战斗结束", "剩余血量: ", ability_component.current_health)
	_current_combat = null
	ability_component.on_combat_end()
	combat_ended.emit()

## 攻击
func hit(target: CombatComponent) -> void:
	if not target: return
	if _current_combat.is_real_time:
		await get_tree().create_timer(0.5).timeout
	if not target: return
	ability_component.on_hit()
	hited.emit(target)
	print(self, " 攻击： ", target)
	var damage : float = ability_component.attack_power - target.ability_component.defense_power
	await target.hurt(self, damage)

## 受击
func hurt(damage_source: CombatComponent, damage: float) -> void:
	ability_component.on_hurt(damage_source, damage)
	hurted.emit(damage)
	print(self, " 受到伤害： ", damage)
	ability_component.current_health -= damage
	ability_component.current_health = max(ability_component.current_health, 0)
	if ability_component.current_health <= 0:
		_die()

## 死亡
func _die() -> void:
	ability_component.on_die()
	print("角色死亡：", self)
	died.emit()

## 获取随机敌人
func _get_random_enemy() -> CombatComponent:
	assert(_current_combat, "当前战斗不存在！不是战斗状态么？")
	return _current_combat.get_random_enemy(self)

## 更新技能组件上下文信息
func _update_ability_component_context() -> void:
	if _current_combat:
		ability_component.enemies = _current_combat.get_all_enemies(self)
		ability_component.allies = _current_combat.get_all_allies(self)
		#ability_component.enemies = _current_combat.get_all_enemies(self).map(
			#func(value: CombatComponent) -> AbilityComponent:
				#return value.ability_component
		#)
		#ability_component.allies = _current_combat.get_all_allies(self).map(
			#func(value: CombatComponent) -> AbilityComponent:
				#return value.ability_component
		#)
	else:
		ability_component.enemies.clear()

func _to_string() -> String:
	return owner.to_string()
