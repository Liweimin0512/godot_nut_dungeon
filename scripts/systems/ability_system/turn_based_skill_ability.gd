extends Ability
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

func _init() -> void:
	# 添加使用次数限制
	add_restriction(UsageCountRestriction.new({
		"max_count": use_count
	}))
	
	# 添加位置限制
	add_restriction(PositionRestriction.new({
		"valid_positions": valid_positions,
		"target_positions": target_positions
	}))

## 获取可选择的目标位置
func get_available_positions(position: int) -> Array:
	if target_range == TARGET_RANGE.SELF:
		return [position]
	elif target_range == TARGET_RANGE.SINGLE_ENEMY or target_range == TARGET_RANGE.SINGLE_ALLY:
		return target_positions
	elif target_range == TARGET_RANGE.ALL_ENEMY or target_range == TARGET_RANGE.ALL_ALLY:
		return valid_positions
	return target_positions
