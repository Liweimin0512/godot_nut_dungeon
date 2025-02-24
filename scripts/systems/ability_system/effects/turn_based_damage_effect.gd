extends BaseDamageEffect
class_name TurnBasedDamageEffect

## 回合制伤害效果

func _calculate_damage(attacker: Node, defender: Node, context: Dictionary) -> void:
	if _is_hit == false:
		context.damage = 0
		return 
		
	# 获取技能伤害信息
	var skill_damage_info = context.get("skill_damage_info", {})
	var skill_base_damage = skill_damage_info.get("base_damage", 0.0)
	var skill_multiplier = skill_damage_info.get("damage_multiplier", 1.0)
	
	# 计算基础伤害
	var base_damage = _get_base_damage(attacker, context)
	base_damage = (base_damage + skill_base_damage) * skill_multiplier
	
	# 计算防御
	var defense = _get_defense(defender)
	
	# 计算暴击
	# 添加技能提供的额外暴击率和暴击伤害
	var crit_rate_bonus = skill_damage_info.get("crit_rate_bonus", 0.0)
	var crit_damage_bonus = skill_damage_info.get("crit_damage_bonus", 0.0)
	var critical_multiplier = _get_crit_multiplier(attacker, context)
	critical_multiplier += crit_damage_bonus  # 添加技能提供的额外暴击伤害
	
	# 重新计算是否暴击，考虑技能提供的额外暴击率
	var crit_rate = _get_crit_rate(attacker) + crit_rate_bonus
	_is_critical = randf() < crit_rate
	
	# 计算最终伤害
	var final_damage = base_damage
	if _is_critical:
		final_damage *= critical_multiplier
	
	# 应用防御减伤
	final_damage = max(1, final_damage - defense)
	
	context.damage = final_damage
	context.is_critical = _is_critical
	context.damage_type = skill_damage_info.get("damage_type", damage_type)
