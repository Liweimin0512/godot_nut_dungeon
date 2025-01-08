extends AbilityResource
class_name ManaResource

## 魔法值资源
## 魔法值是一个属性，在属性改变时同时设置当前资源的最大值
## 随时间（回合）自然恢复

## 初始化
func initialization(ability_component: AbilityComponent) -> void:
	attribute_name = "魔法值"
	ability_resource_name = "魔法值"
	super(ability_component)

## 消耗
func consume(amount: int) -> bool:
	var ok := super(amount)
	if not ok:
		current_value = 0
	return ok
