extends SkillAbility
class_name TurnBasedSkillAbility

## 回合制技能

## 目标范围
enum TARGET_RANGE{
	NONE,			## 无目标
	SINGLE_ENEMY,	## 敌方单个
	SINGLE_ALLY,	## 友方单个
	ALL_ENEMY,		## 全体敌方目标位置
	ALL_ALLY,		## 全体友方目标位置
	SELF,			## 自己
}

## 有效位置
@export var valid_positions : Array = [1, 2, 3, 4]
## 目标位置
@export var target_positions: Array = [1, 2, 3, 4]
## 目标范围
@export var target_range: TARGET_RANGE = TARGET_RANGE.SELF
## 使用次数, 0代表不限次数
@export var use_count: int = 1
## 已经使用的次数
@export_storage var available_count: int = 0
## 剩余使用次数
var left_count : int = 0:
	get:
		return use_count - available_count
@export var is_melee : bool = false

func _ready(config: Dictionary) -> void:
	for i in range(0, config.ability_costs.size(), 2):
		var cost_id : StringName = config.ability_costs[i]
		var cost_amount : int = int(config.ability_costs[i + 1])
		var _cost : AbilityResourceCost = AbilityResourceCost.new(cost_id, cost_amount)
		ability_costs.append(_cost)

## 判断能否在指定位置使用
func can_use_at_position(position: int) -> bool:
	if not is_available:
		return false
	return valid_positions.is_empty() or position in valid_positions

## 获取可选择的目标位置
func get_available_positions(position: int) -> Array:
	if target_range == TARGET_RANGE.SELF:
		return [position]
	elif target_range == TARGET_RANGE.SINGLE_ENEMY or target_range == TARGET_RANGE.SINGLE_ALLY:
		return target_positions
	elif target_range == TARGET_RANGE.ALL_ENEMY or target_range == TARGET_RANGE.ALL_ALLY:
		return valid_positions
	return target_positions

## 回合开始前, 更新技能冷却
func on_pre_turn_start(_data: Dictionary = {}) -> void:
	_update_cooldown(1)
