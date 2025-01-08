extends AbilityCost
class_name AbilityResourceCost

## 技能资源消耗

@export var resource_name: StringName
@export var resource_value: int

func can_cost(context: Dictionary) -> bool:
	var ability = context.get("ability")
	if not ability:
		GASLogger.error("技能{0}消耗资源{1}时，技能不存在".format([self, resource_name]))
		return false
	var resource_component := context.get("resource_component")
	if not resource_component: 
		GASLogger.error("技能{0}消耗资源{1}时，资源组件不存在".format([ability, resource_name]))
		return false
	return resource_component.has_enough_resources(resource_name, resource_value)

func cost(context: Dictionary) -> void:
	var resource_component := context.get("resource_component")
	if not resource_component: 
		GASLogger.error("技能{0}消耗资源{1}时，资源组件不存在".format([ability, resource_name]))
		return
	resource_component.consume_resources(resource_name, resource_value)
