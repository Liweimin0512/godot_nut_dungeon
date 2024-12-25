extends AbilityEffect
class_name RageOnBeginHitEffect

## 受击时（前）概率获得怒气

@export var rage_chance: float = 0.3  # 获得怒气的概率
@export var rage_amount: int = 5  # 获得的怒气值

func _init() -> void:
	effect_type = "rage_on_being_hit"
	target_type = "self"
	target_amount = 1

func apply_effect(context: Dictionary = {}) -> void:
	if randf() > rage_chance: return
	var caster : Node = _context.caster
	var ability_component : AbilityComponent = caster.ability_component
	var rage_resource : AbilityResource = ability_component.get_resource("怒气")
	rage_resource.restore(rage_amount)
	print("受到{0}攻击，触发{1}，获得{2}点怒气".format([
		_context.source, description, rage_amount
	]))
	super()

func on_hurt(context : Dictionary) -> void:
	_context.merge(context, true	)
	apply_effect()

func _description_getter() -> String:
	return "受到攻击时有{0}%的几率获得{1}点怒气".format([
		rage_chance * 100, rage_amount
		])
