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
## 冷却时间（回合数）
@export var cooldown: int
## 技能释放时间（秒）
@export var cast_time: float
## 技能目标类型
@export var target_type: String
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

## ability_component的initialization
func initialization() -> void:
	pass

## 战斗开始
func on_combat_start() -> void:
	pass

## 战斗结束
func on_combat_end() -> void:
	pass

## 回合开始
func on_turn_start() -> void:
	pass

## 回合结束
func on_turn_end() -> void:
	pass

## 造成伤害
func on_hit() -> void:
	pass

## 受到伤害
func on_hurt() -> void:
	pass

## 死亡
func on_die() -> void:
	pass
