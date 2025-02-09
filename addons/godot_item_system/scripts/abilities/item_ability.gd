extends Ability
class_name ItemAbility

## 道具技能基类
## 所有道具效果都继承自这个类

# 属性
var item_instance: ItemInstance
var effects: Dictionary

## 初始化
func initialize(item: ItemInstance) -> void:
	item_instance = item
	effects = item.get_total_effects()

## 应用效果
func apply_effects(target: Node) -> void:
	if not target:
		return
		
	var ability_system = target.get_node_or_null("AbilitySystemComponent")
	if not ability_system:
		return
		
	for effect_name in effects:
		var value = effects[effect_name]
		match effect_name:
			"heal":
				_apply_heal_effect(ability_system, value)
			"attack":
				_apply_attack_effect(ability_system, value)
			"defense":
				_apply_defense_effect(ability_system, value)
			_:
				push_warning("Unknown effect: %s" % effect_name)

## 应用治疗效果
func _apply_heal_effect(ability_system: AbilityComponent, value: float) -> void:
	var health_attribute = ability_system.get_attribute("health")
	if health_attribute:
		health_attribute.current_value += value

## 应用攻击效果
func _apply_attack_effect(ability_system: AbilityComponent, value: float) -> void:
	var attack_attribute = ability_system.get_attribute("attack")
	if attack_attribute:
		attack_attribute.base_value += value

## 应用防御效果
func _apply_defense_effect(ability_system: AbilityComponent, value: float) -> void:
	var defense_attribute = ability_system.get_attribute("defense")
	if defense_attribute:
		defense_attribute.base_value += value
