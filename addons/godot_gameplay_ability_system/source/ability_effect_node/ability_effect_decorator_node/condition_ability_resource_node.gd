extends DecoratorNode
class_name ConditionAbilityResourceNode

## 资源条件判断，是否足够

## 资源名称
@export var ability_resource_name: StringName
## 需要资源值
@export var need_resource_value: float

func _execute(context: Dictionary) -> STATUS:
    if not _check_resource_condition(context):
        return STATUS.FAILURE
    return await child.execute(context) if child else STATUS.FAILURE

func _check_resource_condition(context: Dictionary) -> bool:
    var caster = context.get("caster", null)
    if not caster:
        GASLogger.error("caster is null")
        return false
    var ability_resource_component : AbilityResourceComponent = caster.ability_resource_component
    var resource_value = ability_resource_component.get_resource_value(ability_resource_name)
    if resource_value == null:
        GASLogger.error("{0} : resource_value is null".format([ability_resource_name]))
        return false
    return resource_value >= need_resource_value