extends AbilityEffectActionNode
class_name MoveToCastingPositionEffectNode

## 移动到施法位置

## 技能施法位置
@export var casting_position : AbilityDefinition.CASTING_POSITION = AbilityDefinition.CASTING_POSITION.NONE
@export var action_position_offset : Vector2 = Vector2(50, 0)
@export var move_time : float = 0.4
## 是否等待移动完成
@export var wait_move_complete : bool = true

## 移动到行动位置
func _perform_action(context: Dictionary) -> void:
	var tree : SceneTree = context.get("tree")
	var target_point := _get_action_point(context)
	var tween : Tween = tree.create_tween()
	tween.tween_property(owner, "global_position", target_point, move_time)
	if wait_move_complete:
		await tween.finished

## 获取行动位置
func _get_action_point(context: Dictionary) -> Vector2:
	var point : Vector2
	var caster : Node2D = context.get("caster")
	var target : Node2D = context.get("target")
    if not target:
        return caster.global_position
    var caster_camp : CombatDefinition.COMBAT_CAMP_TYPE = caster.combat_component.combat_camp
	match casting_position:
		AbilityDefinition.CASTING_POSITION.MELEE:
			point = target.global_position + action_position_offset * (Vector2(-1, 0) if caster_camp == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER else Vector2(1, 0))
		AbilityDefinition.CASTING_POSITION.BEHINDENEMY:
			point = target.global_position + action_position_offset * (Vector2(1, 0) if caster_camp == CombatDefinition.COMBAT_CAMP_TYPE.PLAYER else Vector2(-1, 0))
		AbilityDefinition.CASTING_POSITION.NONE:
			point = caster.global_position
		_:
			point = _current_combat.action_marker.position
	return point
