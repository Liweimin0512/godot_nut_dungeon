extends AbilityTargetSelector
class_name TurnBasedTargetSelector

## 回合制目标选择器


## 目标类型
enum TARGET_TYPE {
	SINGLE_ENEMY,       ## 单个敌人（需要选择）
	MULTIPLE_ENEMY,     ## 多个敌人（预设位置，如前排两个位置）
	SINGLE_ALLY,        ## 单个友军
	MULTIPLE_ALLY,      ## 多个友军（不包括自身）
	SELF,               ## 自身
}

var target_type : TARGET_TYPE = TARGET_TYPE.SINGLE_ENEMY
var available_positions : Array = [1, 2, 3, 4]


func _init(config : Dictionary = {}) -> void:
	target_type = config.get("target_type", TARGET_TYPE.SINGLE_ENEMY)
	available_positions = config.get("available_positions", [])


## 获取可用目标
func get_available_targets(ability: Ability, context: Dictionary) -> Array:
	var caster = context.get("caster", null)
	
	if target_type == TARGET_TYPE.SELF:
		return [caster]

	var all_targets = _get_targets_by_camp(ability, context)
	var available_targets = _filter_targets_by_position(all_targets)

	# 应用过滤器
	return available_targets


## 验证目标
func validate_targets(_ability: Ability, targets: Array, _context: Dictionary) -> bool:
	if targets.is_empty():
		return false
		
	# 验证每个目标是否在可用位置
	for target in targets:
		if not target.current_point in available_positions:
			return false
	return true


## 获取实际执行时的目标
## 这些是技能实际生效的目标，可能和选择的目标不同
## 比如：选择一个目标但实际影响多个目标的技能
## 这里的目标类型是预设的，不会因为选择的不同而变化
func get_actual_targets(ability: Ability, selected_targets: Array, context: Dictionary) -> Array:
	match target_type:
		TARGET_TYPE.SELF:
			return [context.get("caster")]
			
		TARGET_TYPE.SINGLE_ENEMY, TARGET_TYPE.SINGLE_ALLY:
			# 单体技能直接返回选择的目标
			return selected_targets
			
		TARGET_TYPE.MULTIPLE_ENEMY, TARGET_TYPE.MULTIPLE_ALLY:
			# 多目标技能返回所有可用位置的目标
			var all_targets = _get_targets_by_camp(ability, context)
			return _filter_targets_by_position(all_targets)
	
	return []


## 根据阵营获取目标
func _get_targets_by_camp(_ability: Ability, context: Dictionary) -> Array:
	var combat_manager = CombatSystem.active_combat_manager
	if not combat_manager:
		return []
	
	var caster : Node = context.get("caster", null)
	if not caster:
		push_error("caster not found!")
		return []

	if target_type == TARGET_TYPE.SINGLE_ENEMY or target_type == TARGET_TYPE.MULTIPLE_ENEMY:
		return combat_manager.get_enemy_units(caster)
	elif target_type == TARGET_TYPE.SINGLE_ALLY or target_type == TARGET_TYPE.MULTIPLE_ALLY:
		return combat_manager.get_ally_units(caster)
	return []


## 根据位置筛选目标
func _filter_targets_by_position(targets: Array) -> Array:
	var available_targets : Array = []
	if target_type == TARGET_TYPE.SINGLE_ALLY or target_type == TARGET_TYPE.MULTIPLE_ALLY:
		available_targets = targets
	else:
		for target in targets:
			if target.combat_point in available_positions:
				available_targets.append(target)
	return available_targets
