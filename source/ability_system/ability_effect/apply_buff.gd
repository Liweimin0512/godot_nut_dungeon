extends AbilityEffect
class_name ApplyBuffEffect

## 对目标应用BUFF的技能效果

@export var buff : AbilityBuff

## 应用效果
func apply_effect(context: Dictionary = {}) -> void:
	var targets := _get_targets()
	#TODO 这里应该分情况讨论，目标是继承还是重新获取，这里简化了
	for target in targets:
		var ability_component : AbilityComponent = target.ability_component
		ability_component.apply_buff(buff)
		print("对目标应用BUFF效果")
	super(context)
