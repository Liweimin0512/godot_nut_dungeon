extends AbilityResource
class_name HealthResource

## 生命值，适合邪恶、残暴单位
## 最大值对应生命值属性，属性概念时需要更新最大值

func _init() -> void:
	ability_resource_name = "生命值"
	attribute_name = "max_health"
