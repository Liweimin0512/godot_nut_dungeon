extends Ability
class_name SkillAbility

## 技能

## 目标类型，如self, ally, enemy
@export var target_type: StringName
## 消耗资源
@export var cost_resource_name: StringName = ""
## 消耗资源值
@export var cost_resource_value: int = 0
## 技能是否在满足条件时自动施放
@export var is_auto_cast: bool
## 冷却时间（回合数）
@export var cooldown: int
## 当前冷却时间
@export_storage var current_cooldown : int = 0:
	set(value):
		current_cooldown = value
		cooldown_changed.emit(current_cooldown)
## 技能是否显示在UI中
@export var is_show : bool = true
## 是否正处在冷却状态
var is_cooldown: bool:
	get:
		return current_cooldown > 0

signal cooldown_changed(value: int) 

func _init() -> void:
	resource_local_to_scene = true

## 应用技能
func _apply(context: Dictionary) -> void:
	if is_auto_cast:
		_ability_component.try_cast_ability(self, context)

## 执行技能
func _cast(context: Dictionary) -> bool:
	if not _ability_component.has_enough_resources(cost_resource_name, cost_resource_value):
		print("消耗不足，无法释放技能！")
		return false
	if is_cooldown:
		print("技能正在冷却！")
		return false
	var caster : Node = context.get("caster")
	var target : Node
	if target_type == "self":
		target = caster
	else:
		target = context.get("target", null)
	_ability_component.consume_resources(cost_resource_name, cost_resource_value)
	current_cooldown = cooldown
	context.merge({"target": target}, true)
	var ok := await super(context)
	return ok

## 更新冷却时间
func _update_cooldown(amount: int) -> void:
	if is_cooldown:
		current_cooldown -= amount

func _to_string() -> String:
	return "{0}冷却{1}".format([ability_name, current_cooldown])
