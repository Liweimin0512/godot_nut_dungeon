class_name ConditionDecoratorNode
extends EffectDecoratorNode

## 条件装饰器：根据条件决定是否执行子节点
enum ConditionType {
    HEALTH_PERCENTAGE,    # 生命值百分比
    RESOURCE_AVAILABLE,   # 资源是否足够
    HAS_BUFF,            # 是否有特定buff
    DISTANCE_TO_TARGET,  # 与目标距离
    CUSTOM              # 自定义条件
}

@export var condition_type: ConditionType
@export var condition_value: float
@export var comparison_operator: String = ">" # >, <, >=, <=, ==

func _execute(context: Dictionary) -> STATUS:
    if not _check_condition(context):
        return STATUS.FAILURE
    return child.execute(context) if child else STATUS.FAILURE

func _check_condition(context: Dictionary) -> bool:
    match condition_type:
        ConditionType.HEALTH_PERCENTAGE:
            return _check_health_condition(context)
        ConditionType.RESOURCE_AVAILABLE:
            return _check_resource_condition(context)
        ConditionType.HAS_BUFF:
            return _check_buff_condition(context)
        ConditionType.DISTANCE_TO_TARGET:
            return _check_distance_condition(context)
        ConditionType.CUSTOM:
            return _check_custom_condition(context)
    return false