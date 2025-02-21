extends Ability
class_name ContinuousAbility

## 连续性技能

func _init() -> void:
    # 添加冷却限制
    add_restriction(CooldownRestriction.new({
        "cooldown": 10.0
    }))
    
    # 添加资源消耗限制
    add_restriction(ResourceCostRestriction.new({
        "cost_resource_id": "mana",
        "cost_value": 50
    }))