extends ControlNode
class_name ControlParallelNode

## 并行节点：同时执行所有子节点
enum POLICY {
	REQUIRE_ALL,    # 所有子节点都成功才算成功
	REQUIRE_ONE     # 一个子节点成功就算成功
}

## 成功策略：所有子节点都成功才算成功，或者只要一个子节点成功就算成功
@export var success_policy: POLICY = POLICY.REQUIRE_ALL

func _execute(context: Dictionary) -> STATUS:
	for child in children:
		await child.execute(context)
		if success_policy == POLICY.REQUIRE_ONE:
			return STATUS.SUCCESS
	if success_policy == POLICY.REQUIRE_ALL:
		return STATUS.SUCCESS
	return STATUS.FAILURE

func _revoke() -> STATUS:
	for child in children:
		await child.revoke()
		if success_policy == POLICY.REQUIRE_ONE:
			return STATUS.SUCCESS
	if success_policy == POLICY.REQUIRE_ALL:
		return STATUS.SUCCESS
	return STATUS.FAILURE
