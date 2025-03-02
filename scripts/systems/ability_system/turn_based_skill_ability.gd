extends Ability
class_name TurnBasedSkillAbility

## 回合制技能

@export var ability_name: StringName							## 技能名称
@export var ability_description: String							## 技能描述
@export var icon: Texture2D										## 技能图标
@export var is_melee : bool = true								## 是否近战

# 伤害修正相关
@export var damage_randomness: float = 0.0      				## 伤害浮动
@export var damage_multiplier: float = 1.0      				## 伤害修正倍率
@export var crit_rate_bonus: float = 0.0        				## 暴击修正倍数
@export var hit_rate_bonus: float = 0.0         				## 命中修正倍数

var position_restriction : CastPositionRestriction				## 位置限制
var usage_count_restriction : UsageCountRestriction				## 使用次数限制

var _target_selector : TurnBasedTargetSelector					## 目标选择器


func _init() -> void:
	add_tag("skill")


## 从数据字典初始化
## [param data] 数据字典
func _init_from_data(data : Dictionary) -> void:
	super(data)

	var use_count = data.get("use_count", 0)
	if use_count > 0:
		# 添加使用次数限制
		usage_count_restriction = add_restriction(UsageCountRestriction.new({
			"max_count": use_count,
		}))

	# 添加位置限制
	position_restriction = add_restriction(CastPositionRestriction.new({
		"valid_positions": data.get("valid_positions", [1, 2, 3, 4]),
	}))

	_target_selector = TurnBasedTargetSelector.new({
		"target_type": data.get("target_type", TurnBasedTargetSelector.TARGET_TYPE.SINGLE_ENEMY),
		"available_positions": data.get("target_positions", [1, 2, 3, 4]),
	})


func execute(context: Dictionary) -> void:
	var selected_targets = context.get("targets", [])
	
	# 获取实际执行时的目标
	var actual_targets = _target_selector.get_actual_targets(self, selected_targets, context)
	
	# 添加技能伤害相关信息到上下文
	context["targets"] = actual_targets
	context["skill_damage_info"] = {
		"damage_randomness": damage_randomness,
		"damage_multiplier": damage_multiplier,
		"crit_rate_bonus": crit_rate_bonus,
		"hit_rate_bonus": hit_rate_bonus
	}
	await super(context)


func get_full_description() -> String:
	var desc = []
	desc.append(ability_description)

	# 获得行为树的效果描述
	var action_tree_desc : String = AbilitySystem.action_tree_manager.get_tree_description(self)
	if not action_tree_desc.is_empty():
		desc.append("\n")
		desc.append(action_tree_desc)

	return "\n".join(desc)


func get_actual_targets(selected_targets: Array, context: Dictionary) -> Array:
	return _target_selector.get_actual_targets(self, selected_targets, context)


## 获取伤害最小值
func get_min_damage(caster: Node) -> float:
	if not caster:
		GASLogger.error("caster is null")
		return 1.0
	
	var attack = caster.ability_attribute_component.get_attribute_value("attack")
	return attack * (damage_multiplier - damage_randomness)


## 获取伤害最大值
func get_max_damage(caster: Node) -> float:
	if not caster:
		GASLogger.error("caster is null")
		return 1.0
	
	var attack = caster.ability_attribute_component.get_attribute_value("attack")
	return attack * (damage_multiplier + damage_randomness)


## 获取技能暴击倍数
func get_crit_rate(caster: Node) -> float:
	if not caster:
		GASLogger.error("caster is null")
		return 1.0
	
	var base_crit_rate = caster.ability_attribute_component.get_attribute_value("crit_rate")
	return base_crit_rate + crit_rate_bonus


## 获取技能命中倍数
func get_hit_rate(caster: Node) -> float:
	if not caster:
		GASLogger.error("caster is null")
		return 1.0
	
	var base_hit_rate = caster.ability_attribute_component.get_attribute_value("hit_rate")
	return base_hit_rate + hit_rate_bonus


## 获取有效目标位置
func get_available_target_positions() -> Array:
	return _target_selector.available_positions


## 获取技能目标选择器
func _get_target_selector() -> AbilityTargetSelector:
	return _target_selector
