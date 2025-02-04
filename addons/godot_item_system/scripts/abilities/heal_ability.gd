extends ItemAbility
class_name HealAbility

## 治疗技能
## 用于恢复生命值的道具技能

func _activate(payload: Dictionary) -> void:
	# 检查消耗品
	if not item_instance:
		return
		
	# 获取目标
	var target = payload.get("target", owner)
	if not target:
		return
		
	# 应用效果
	apply_effects(target)
	
	# 播放效果
	_play_effects(target)
	
	# 完成技能
	end_ability()

## 播放效果
func _play_effects(target: Node) -> void:
	# TODO: 添加治疗特效
	pass
