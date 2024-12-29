extends Resource
class_name Ability

## 技能名称
@export var ability_name : StringName = ""
## 技能描述
@export var ability_description: String = ""
## 技能在UI中显示的图标
@export var icon: Texture
# 技能触发器，自动释放技能必须配置触发器
@export var trigger: AbilityTrigger
## 技能的等级，影响技能的效果
@export var level: int = 1
## 技能产生的效果列表，可能包括伤害、治疗、控制等。
@export var effects: Array[AbilityEffect]
## 所属技能组件
var _ability_component: AbilityComponent

signal cast_finished

## 技能初始化
func initialization(ability_component: AbilityComponent, context: Dictionary) -> void:
	_ability_component = ability_component
	for effect in effects:
		effect.applied.connect(
			func() -> void:
				cast_finished.emit()
				print("技能{0}效果触发:{1}".format([self, effect.description]))
		)

func _to_string() -> String:
	return ability_name
