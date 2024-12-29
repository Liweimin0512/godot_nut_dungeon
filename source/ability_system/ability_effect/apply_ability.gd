extends AbilityEffect
class_name ApplyAbilityEffect

## 对目标应用技能的效果

@export var ability : Ability

## 应用效果
func apply_effect(context: Dictionary = {}) -> void:
	var targets := _get_targets(context)
	#TODO 这里应该分情况讨论，目标是继承还是重新获取，这里简化了
	for target in targets:
		var ability_component : AbilityComponent = target.ability_component
		ability_component.apply_ability(ability, context)
		print("对目标应用Ability:{0}".format([ability]))
	super(context)
