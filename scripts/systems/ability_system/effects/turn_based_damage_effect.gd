extends BaseDamageEffect
class_name TurnBasedDamageEffect

## 回合制伤害效果

func _calculate_damage(attacker: Node, defender: Node, context: Dictionary) -> void:
	# 获取技能伤害信息
	var skill_damage_info = context.get("skill_damage_info", {})
	
	# 计算命中
	var hit_rate_bonus = skill_damage_info.get("hit_rate_bonus", 0.0)
	_is_hit = _roll_hit_with_bonus(attacker, defender, hit_rate_bonus)
	if not _is_hit:
		context.damage = 0
		return
	
	# 计算基础伤害
	var base_damage = _get_base_damage(attacker, context)
	
	# 应用伤害浮动
	var damage_randomness = skill_damage_info.get("damage_randomness", 0.0)
	if damage_randomness > 0:
		var random_factor = 1.0 + randf_range(-damage_randomness, damage_randomness)
		base_damage *= random_factor
	
	# 应用技能伤害倍率
	var skill_multiplier = skill_damage_info.get("damage_multiplier", 1.0)
	base_damage *= skill_multiplier
	
	# 计算防御
	var defense = _get_defense(defender)
	
	# 计算暴击
	var crit_rate_bonus = skill_damage_info.get("crit_rate_bonus", 0.0)
	var base_crit_rate = _get_crit_rate(attacker)
	_is_critical = randf() < (base_crit_rate * (1.0 + crit_rate_bonus))
	
	# 应用暴击伤害
	if _is_critical:
		base_damage *= _get_crit_multiplier(attacker, context)
	
	# 应用防御减伤
	var final_damage = max(1, base_damage - defense)
	
	context.damage = final_damage
	context.is_critical = _is_critical
	context.damage_type = skill_damage_info.get("damage_type", damage_type)


## 带加成的命中判定
func _roll_hit_with_bonus(attacker: Node, defender: Node, hit_rate_bonus: float) -> bool:
	var hit_rate = _get_hit_rate(attacker)
	var dodge_rate = _get_dodge_rate(defender)
	
	# 应用命中率加成
	hit_rate *= (1.0 + hit_rate_bonus)
	
	# 计算最终命中率
	var final_hit_rate = max(min_hit_rate, hit_rate - dodge_rate)
	return randf() < final_hit_rate


## 获取动作描述
func _get_action_description() -> String:
	return ""