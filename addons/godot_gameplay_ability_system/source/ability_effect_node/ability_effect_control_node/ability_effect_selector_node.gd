extends AbilityEffectControlNode
class_name AbilityEffectSelectorNode

## 选择节点：执行子节点直到一个成功

func _execute(context: Dictionary) -> STATUS:
	for child in children:
		var status = await child.execute(context)
		if status != STATUS.FAILURE:
			return status
	return STATUS.FAILURE

func _revoke() -> STATUS:
	for child in children:
		var status = await child.revoke()
		if status != STATUS.SUCCESS:
			return status
	return STATUS.SUCCESS
