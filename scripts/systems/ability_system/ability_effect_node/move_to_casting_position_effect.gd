extends AbilityAction
class_name MoveToCastingPositionEffectNode

## 移动到施法位置

## 技能施法位置
@export var casting_position_type : AbilityDefinition.CASTING_POSITION_TYPE = AbilityDefinition.CASTING_POSITION_TYPE.NONE
@export var action_position_offset : Vector2 = Vector2(50, 0)
@export var move_time : float = 0.4
## 是否等待移动完成
@export var wait_move_complete : bool = true

## 移动到行动位置
func _perform_action(context: Dictionary) -> STATUS:
	var tree : SceneTree = context.get("tree")
	var caster : CombatComponent = _get_context_value(context, "caster")
	var target_point := _get_action_point(caster, context)
	var tween : Tween = tree.create_tween()
	tween.tween_property(caster.owner, "global_position", target_point, move_time)
	if wait_move_complete:
		await tween.finished
	return STATUS.SUCCESS

## 获取行动位置
func _get_action_point(caster : CombatComponent, context: Dictionary) -> Vector2:
	var point : Vector2
	var target : CombatComponent = _get_context_value(context, "target")
	var owner : Node2D = caster.owner
	if not target:
		point = owner.global_position
	var caster_camp : CombatDefinition.COMBAT_CAMP_TYPE = caster.combat_camp
	match casting_position_type:
		AbilityDefinition.CASTING_POSITION_TYPE.MELEE:
			point = target.owner.global_position + action_position_offset * (Vector2(-1, 0) if caster_camp == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER else Vector2(1, 0))
		AbilityDefinition.CASTING_POSITION_TYPE.BEHINDENEMY:
			point = target.owner.global_position + action_position_offset * (Vector2(1, 0) if caster_camp == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER else Vector2(-1, 0))
		AbilityDefinition.CASTING_POSITION_TYPE.RANGED:
			var casting_point : Vector2 = _get_context_value(context, "casting_point")
			point = casting_point
		_:
			point = owner.global_position
	return point
