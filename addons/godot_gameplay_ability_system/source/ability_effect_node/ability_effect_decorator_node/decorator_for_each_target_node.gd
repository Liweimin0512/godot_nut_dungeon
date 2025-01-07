extends DecoratorNode
class_name DecoratorForEachTargetNode

## 遍历所有符合条件的目标，对每个目标执行子节点

## 目标类型，self: 自身，ally: 友军，enemy: 敌军，all: 所有
@export_enum("self", "ally", "enemy", "all") var target_type : String = "self"
## 目标列表
var _targets : Array = []

func _execute(context: Dictionary) -> STATUS:
	var enemies = context.get("enemies")
	var allies = context.get("allies")
	var caster = context.get("caster")
   # 根据目标类型获取目标列表
	match target_type:
		"self":
			_targets = [caster] if caster else []
		"ally":
			_targets = allies
		"enemy":
			_targets = enemies
		"all":
			_targets = allies + enemies
	# 如果没有找到目标，返回失败
	if _targets.is_empty():
		return STATUS.FAILURE
	
	# 对每个目标执行子节点
	var overall_status = STATUS.SUCCESS
	for target in _targets:
		# 创建新的上下文，避免修改原始上下文
		var target_context = context.duplicate()
		target_context["target"] = target
		
		# 执行子节点
		var status = await child.execute(target_context) if child else STATUS.FAILURE
		
		# 如果任一执行失败，记录但继续执行其他目标
		if status != STATUS.SUCCESS:
			overall_status = STATUS.FAILURE
	
	return overall_status

func _revoke() -> STATUS:
	var overall_status = STATUS.SUCCESS
	for target in _targets:
		var result = await child.revoke()
		if result == STATUS.FAILURE:
			overall_status = STATUS.FAILURE
	_targets.clear()
	return overall_status
