class_name ParallelNode
extends ControlNode

## 并行节点：同时执行所有子节点
enum POLICY {
    REQUIRE_ALL,    # 所有子节点都成功才算成功
    REQUIRE_ONE     # 一个子节点成功就算成功
}

@export var success_policy: POLICY = POLICY.REQUIRE_ALL

func _execute(context: Dictionary) -> STATUS:
    var success_count := 0
    var running_count := 0
    
    for child in children:
        var status = child.execute(context)
        match status:
            STATUS.SUCCESS:
                success_count += 1
            STATUS.RUNNING:
                running_count += 1
    
    if success_policy == POLICY.REQUIRE_ONE and success_count > 0:
        return STATUS.SUCCESS
    if success_policy == POLICY.REQUIRE_ALL and success_count == children.size():
        return STATUS.SUCCESS
    if running_count > 0:
        return STATUS.RUNNING
    return STATUS.FAILURE