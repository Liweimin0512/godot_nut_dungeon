extends Ability
class_name SkillAbility

## 技能

## 目标类型，如self, ally, enemy
@export var target_type: StringName
## 目标数量
@export var target_amount: int = 1
## 消耗资源
@export var cost_resource_name: StringName = ""
## 消耗资源值
@export var cost_resource_value: int = 0
## 技能是否在满足条件时自动施放
@export var is_auto_cast: bool
## 冷却时间（回合数）
@export var cooldown: int
## 当前冷却时间
@export_storage var current_cooldown : int = 0
## 技能释放时间（秒）
@export var cast_time: float
## 技能是否显示在UI中
@export var is_show : bool = true
## 技能释放时播放的音效
@export var sound_effect: StringName
## 技能释放时播放的动画
@export var animation: StringName
## 是否正处在冷却状态
var is_cooldown: bool:
	get:
		return current_cooldown > 0

## 应用技能
func apply(ability_component: AbilityComponent, context: Dictionary) -> void:
	if is_auto_cast and trigger == null:
		ability_component.try_cast_ability(self, context)
	super(ability_component, context)

## 移除技能
func remove(context: Dictionary = {}) -> void:
	super(context)

## 执行技能
func cast(context: Dictionary) -> bool:
	if not _ability_component.has_enough_resources(cost_resource_name, cost_resource_value):
		print("消耗不足，无法释放技能！")
		return false
	if is_cooldown:
		print("技能正在冷却！")
		return false
	if cast_time > 0:
		await _ability_component.get_tree().create_timer(cast_time).timeout
	_ability_component.consume_resources(cost_resource_name, cost_resource_value)
	current_cooldown = cooldown
	return super(context)

## 更新冷却时间
func update_cooldown() -> void:
	if is_cooldown:
		current_cooldown -= 1
