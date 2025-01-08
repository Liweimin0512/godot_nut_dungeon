extends Ability
class_name SkillAbility

## 技能

## 目标类型，如self, ally, enemy
@export var target_type: StringName
## 技能消耗
@export var ability_cost: AbilityCost
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

## 能否施放
var can_cast: bool:
	get:
		return ability_cost.can_cost(_context) if ability_cost else true

signal cooldown_changed(value: int) 

func _init() -> void:
	resource_local_to_scene = true
	ability_tags.append("skill")

## 判断能否施放
func _can_cast(context: Dictionary) -> bool:
	if is_cooldown:
		print("技能正在冷却！")
		return false
	if ability_cost and not ability_cost.can_cost(context):
		print("消耗不足，无法释放技能！")
		return false
	elif ability_cost:
		ability_cost.cost(context)
	return true

## 执行技能
func _cast(context: Dictionary) -> bool:
	var caster : Node = context.get("caster")
	var target : Node
	if target_type == "self":
		target = caster
	else:
		target = context.get("target", null)
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
