extends Ability
class_name TurnBasedSkillAbility

## 回合制技能

@export var ability_name: StringName			## 技能名称
@export var ability_description: String			## 技能描述
@export var icon: Texture2D						## 技能图标
@export var is_melee : bool = true				## 是否近战

# 伤害修正相关
@export var base_damage: float = 0.0             ## 基础伤害
@export var damage_multiplier: float = 1.0       ## 伤害倍率
@export var damage_type: StringName = "physical" ## 伤害类型
@export var crit_rate_bonus: float = 0.0        ## 额外暴击率
@export var crit_damage_bonus: float = 0.0      ## 额外暴击伤害

var position_restriction : CastPositionRestriction
var usage_count_restriction : UsageCountRestriction

var _target_selector : TurnBasedTargetSelector

func _init() -> void:
	add_tag("skill")

## 从数据字典初始化
## [param data] 数据字典
func _init_from_data(data : Dictionary) -> void:
	super(data)

	# 添加使用次数限制
	usage_count_restriction = add_restriction(UsageCountRestriction.new({
		"max_count": data.get("use_count", 0),
	}))

	# 添加位置限制
	position_restriction = add_restriction(CastPositionRestriction.new({
		"valid_positions": data.get("valid_positions", [1, 2, 3, 4]),
	}))

	_target_selector = TurnBasedTargetSelector.new({
		"target_type": data.get("target_type", TurnBasedTargetSelector.TARGET_TYPE.SINGLE_ENEMY),
		"available_positions": data.get("available_positions", [1, 2, 3, 4]),	
	})

## 获取技能描述（包含伤害信息）
func get_full_description() -> String:
	var desc = []
	desc.append(ability_description)
	
	# 添加伤害相关描述
	if base_damage > 0:
		desc.append("\n基础伤害：%.1f" % base_damage)
		if damage_multiplier != 1.0:
			desc.append("伤害倍率：%.1fx" % damage_multiplier)
	
	if crit_rate_bonus > 0:
		desc.append("额外暴击率：+%.1f%%" % (crit_rate_bonus * 100))
	if crit_damage_bonus > 0:
		desc.append("额外暴击伤害：+%.1f%%" % (crit_damage_bonus * 100))
	
	return "\n".join(desc)

func execute(context: Dictionary) -> void:
	var selected_targets = _target_selector.get_selected_targets(self, context)
	# 获取实际执行时的目标
	var actual_targets = _target_selector.get_actual_targets(self, selected_targets, context)
	
	# 添加技能伤害相关信息到上下文
	context["targets"] = actual_targets
	context["skill_damage_info"] = {
		"base_damage": base_damage,
		"damage_multiplier": damage_multiplier,
		"damage_type": damage_type,
		"crit_rate_bonus": crit_rate_bonus,
		"crit_damage_bonus": crit_damage_bonus
	}

	super(context)

## 获取有效目标位置
func get_available_target_positions() -> Array:
	return _target_selector.available_positions

## 获取技能目标选择器
func _get_target_selector() -> AbilityTargetSelector:
	return _target_selector
