extends Resource
class_name Ability

## 技能名称
@export var ability_name : StringName = ""
## 技能描述
@export var ability_description: String = ""
## 消耗资源
@export var cost_resource_name: StringName = ""
## 消耗资源值
@export var cost_resource_value: int = 0
## 目标类型，如self, ally, enemy
@export var target_type: StringName
## 目标数量
@export var target_amount: int = 1
## 冷却时间（回合数）
@export var cooldown: int
## 当前冷却时间
@export_storage var current_cooldown : int = 0
## 技能释放时间（秒）
@export var cast_time: float
## 技能产生的效果列表，可能包括伤害、治疗、控制等。
@export var effects: Array[AbilityEffect]
## 技能是否在满足条件时自动施放
@export var is_auto_cast: bool
## 技能的等级，影响技能的效果
@export var level: int = 1
## 技能是否显示在UI中
@export var is_show : bool = true
## 技能在UI中显示的图标
@export var icon: Texture
## 技能释放时播放额音效
@export var sound_effect: StringName
## 技能释放时播放的动画
@export var animation: StringName
## 当前技能否可用
@export var is_available: bool:
	get:
		if is_cooldown or not has_enough_resources or is_auto_cast:
			return false
		return true
## 是否正处在冷却状态
@export var is_cooldown: bool:
	get:
		return current_cooldown > 0
## 是否消耗足够
@export var has_enough_resources: bool:
	get:
		var caster : Node = _context.caster
		var ability_component: AbilityComponent = caster.get("ability_component")
		if ability_component:
			return ability_component.has_enough_resources(cost_resource_name, cost_resource_value)
		return false

## 技能上下文
var _context : Dictionary = {}

signal cast_finished

## ability_component的initialization
func initialization(context: Dictionary) -> void:
	_context = context
	for effect : AbilityEffect in effects:
		effect.initialization(_context)
		effect.applied.connect(
			func() -> void:
				cast_finished.emit()
				print("技能效果触发", self)
		)

## 释放
func cast(targets : Array) -> void:
	if has_enough_resources:
		var caster : Node = _context.caster
		var ability_component: AbilityComponent = caster.ability_component
		ability_component.consume_resources(cost_resource_name, cost_resource_value)
		var context : Dictionary = {} if targets.is_empty() else {
			"targets" : targets
		}
		print("ability: {0}释放技能：{1}".format([caster, self]))
		_apply_effects(context)
		current_cooldown = cooldown
	else:
		print("Not enough resources to cast this ability.")

## 更新技能上下文
func update_context(context: Dictionary) -> void:
	_context.merge(context, true	)

## 应用效果
func _apply_effects(context : Dictionary = {}) -> void:
	for effect : AbilityEffect in effects:
		effect.apply_effect(context)

#region 技能触发时机回调

## 战斗开始
func on_combat_start() -> void:
	if current_cooldown >= 0:
		current_cooldown -= 1
	for effect : AbilityEffect in effects:
		effect.on_combat_start()

## 战斗结束
func on_combat_end() -> void:
	for effect : AbilityEffect in effects:
		effect.on_combat_end()

## 回合开始
func on_turn_start() -> void:
	for effect : AbilityEffect in effects:
		effect.on_turn_start()

## 回合结束
func on_turn_end() -> void:
	for effect : AbilityEffect in effects:
		effect.on_turn_end()

## 造成伤害
func on_hit() -> void:
	for effect : AbilityEffect in effects:
		effect.on_hit()

## 受到伤害
func on_hurt(context: Dictionary) -> void:
	_context.merge(context, true	)
	for effect : AbilityEffect in effects:
		effect.on_hurt(_context)

## 死亡
func on_die() -> void:
	for effect : AbilityEffect in effects:
		effect.on_die()

#endregion

func _to_string() -> String:
	return ability_name
