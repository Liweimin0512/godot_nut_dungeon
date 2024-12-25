extends Resource
class_name Ability

## 技能名称
@export var ability_name : StringName = ""
## 技能描述
@export var ability_description: String = ""
## 消耗资源
@export var cost_resource_name: StringName = ""
## 消耗资源值
@export var cost_resource_value: int = 0
## 目标类型，如self, ally, enemy
@export var target_type: StringName
## 目标数量
@export var target_amount: int = 1
## 冷却时间（回合数）
@export var cooldown: int
## 当前冷却时间
@export_storage var current_cooldown : int = 0
## 技能释放时间（秒）
@export var cast_time: float
## 技能产生的效果列表，可能包括伤害、治疗、控制等。
@export var effects: Array[AbilityEffect]
## 技能是否在满足条件时自动施放
@export var is_auto_cast: bool
## 技能的等级，影响技能的效果
@export var level: int = 1
## 技能是否显示在UI中
@export var is_show : bool = true
## 技能在UI中显示的图标
@export var icon: Texture
## 技能释放时播放额音效
@export var sound_effect: StringName
## 技能释放时播放的动画
@export var animation: StringName
## 是否正处在冷却状态
var is_cooldown: bool:
	get:
		return current_cooldown > 0

signal cast_finished

## 技能初始化
func initialization(context: Dictionary) -> void:
	for effect in effects:
		effect.update_context(context)
		effect.applied.connect(
			func() -> void:
				cast_finished.emit()
				print("技能{0}效果触发:{1}".format([self, effect.description]))
		)

func _to_string() -> String:
	return ability_name
