extends ControlNode
class_name ControlParallelNode

## 并行节点：同时执行所有子节点

enum POLICY {
	REQUIRE_ALL,    # 所有子节点都成功才算成功
	REQUIRE_ONE     # 一个子节点成功就算成功
}

## 成功策略：所有子节点都执行完才算成功，或者只要一个子节点成功就算成功
@export var success_policy: POLICY = POLICY.REQUIRE_ALL
## 当前状态
var status_type: STATUS = STATUS.FAILURE
## 已经执行的子节点
var _executed_children: Array[ControlNode] = []
## 所有子节点执行完毕
signal all_children_executed
## 所有子节点撤销完毕
signal all_children_revoked

func _execute(context: Dictionary) -> STATUS:
	for child in children:
		if not child.executed.is_connected(_on_child_executed):
			child.executed.connect(_on_child_executed.bind(child))
	for child in children:
		child.execute(context)
	await all_children_executed
	return status_type

func _revoke() -> STATUS:
	for child in children:
		if not child.is_connected("revoked", _on_child_revoked):
			child.revoked.connect(_on_child_revoked.bind(child))
		child.revoke()
	await revoked
	return status_type

func _on_child_executed(status: STATUS, child: AbilityEffectActionNode) -> void:
	_executed_children.append(child)
	if success_policy == POLICY.REQUIRE_ONE:
		status_type = STATUS.SUCCESS
		all_children_executed.emit()
	else:
		# 所有子节点都执行完了
		if _executed_children.size() >= children.size():
			status_type = STATUS.SUCCESS
			all_children_executed.emit()

func _on_child_revoked(status: STATUS, child: AbilityEffectNode) -> void:
	_executed_children.erase(child)
	if success_policy == POLICY.REQUIRE_ONE:
		status_type = STATUS.SUCCESS
		all_children_revoked.emit()
	else:
		if _executed_children.is_empty():
			status_type = STATUS.SUCCESS
			all_children_revoked.emit()
