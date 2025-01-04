class_name ProjectileBehaviorFactory
extends Resource

## 行为工厂：创建和管理投射物行为
var _behaviors: Dictionary = {}

## 初始化
func setup(behaviors: Dictionary = {}) -> void:
    # 注册默认行为
    register_behavior("linear", LinearProjectileBehavior.new())
    register_behavior("homing", HomingProjectileBehavior.new())
    register_behavior("parabolic", ParabolicProjectileBehavior.new())
    _behaviors.merge(behaviors, true)

func register_behavior(name: String, behavior: ProjectileBehavior) -> void:
    _behaviors[name] = behavior

func create_behavior(type: String) -> ProjectileBehavior:
    return _behaviors.get(type, LinearProjectileBehavior.new())