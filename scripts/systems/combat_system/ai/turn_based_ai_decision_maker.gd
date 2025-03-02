extends AIDecisionMaker
class_name TurnBasedAIDecisionMaker

## 回合制AI决策器


func select_ability(abilities : Array[Ability]) -> Ability:
	if abilities.is_empty():
		return null
	
	# 按优先级排序可用的技能
	var usable_abilities : Array[Ability] = abilities.filter(func(ability) -> bool:
		return ability.can_execute() and not ability.get_available_targets().is_empty()
	)

	if usable_abilities.is_empty():
		return null

	# 选择优先级最高的技能
	# TODO: 这里可以实现更复杂的选择逻辑
	# 例如：考虑当前生命值、是否有增益、减益效果等
	usable_abilities.shuffle()
	return usable_abilities[0]


## 选择目标
## 基于技能类型和目标状态选择最佳目标
func select_target(ability: Ability, possible_targets: Array) -> Node:
	if possible_targets.is_empty():
		return null

	# 获取技能类型
	if ability.has_tag("damage"):
		# 对于伤害技能，选择生命值最低的目标
		return _select_lowest_health_target(possible_targets)
	elif ability.has_tag("heal"):
		# 对于治疗技能，选择受伤最重的友方目标
		return _select_most_injured_target(possible_targets)
	elif ability.has_tag("buff"):
		# 对于增益技能，选择最强力的友方目标
		return _select_strongest_ally(possible_targets)
	elif ability.has_tag("debuff"):
		# 对于减益技能，选择最危险的敌方目标
		return _select_most_dangerous_target(possible_targets)
	else:
		# 默认选择随机目标
		return possible_targets.pick_random() as Node


## 选择生命值最低的目标
func _select_lowest_health_target(targets: Array) -> Node:
	var selected = targets[0]
	var lowest_health = _get_health_percentage(selected)
	
	for target in targets:
		var health = _get_health_percentage(target)
		if health < lowest_health:
			selected = target
			lowest_health = health
	
	return selected


## 选择受伤最重的目标
func _select_most_injured_target(targets: Array) -> Node:
	var selected = targets[0]
	var most_injured = 1.0 - _get_health_percentage(selected)
	
	for target in targets:
		var injured = 1.0 - _get_health_percentage(target)
		if injured > most_injured:
			selected = target
			most_injured = injured
	
	return selected


## 选择最强力的友方目标
func _select_strongest_ally(targets: Array) -> Node:
	var selected = targets[0]
	var highest_power = _get_power_rating(selected)
	
	for target in targets:
		var power = _get_power_rating(target)
		if power > highest_power:
			selected = target
			highest_power = power
	
	return selected


## 选择最危险的敌方目标
func _select_most_dangerous_target(targets: Array) -> Node:
	var selected = targets[0]
	var highest_threat = _get_threat_rating(selected)
	
	for target in targets:
		var threat = _get_threat_rating(target)
		if threat > highest_threat:
			selected = target
			highest_threat = threat
	
	return selected


## 获取目标生命值百分比
func _get_health_percentage(target: Node) -> float:
	if not target:
		return 0.0
		
	var ability_resource_component: AbilityResourceComponent = target.get_node_or_null("AbilityResourceComponent")
	if not ability_resource_component:
		return 0.0
		
	var percent_health = ability_resource_component.get_resource_percent("health")
	return percent_health if percent_health > 0.0 else 0.0


## 获取目标力量评级
func _get_power_rating(target: Node) -> float:
	if not target:
		return 0.0
		
	var attribute_component = target.get_node_or_null("AbilityAttributeComponent")
	if not attribute_component:
		return 0.0
		
	# 可以基于多个属性计算力量评级
	var attack = attribute_component.get_attribute_value("attack")
	var defense = attribute_component.get_attribute_value("defense")
	
	return attack * 0.7 + defense * 0.3


## 获取目标威胁评级
func _get_threat_rating(target: Node) -> float:
	if not target:
		return 0.0
		
	var attribute_component = target.get_node_or_null("AbilityAttributeComponent")
	if not attribute_component:
		return 0.0
		
	# 可以基于多个因素计算威胁评级
	var attack = attribute_component.get_attribute_value("attack")
	var health = attribute_component.get_attribute_value("health")
	
	return attack * 0.6 + health * 0.4
