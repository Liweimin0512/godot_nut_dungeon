extends Ability
class_name SkillAbility

## 技能

## 目标类型，如self, ally, enemy
@export var target_type: StringName
## 目标数量
@export var target_amount: int = 1
## 消耗资源
@export var cost_resource_name: StringName = ""
## 消耗资源值
@export var cost_resource_value: int = 0
## 技能是否在满足条件时自动施放
@export var is_auto_cast: bool
## 冷却时间（回合数）
@export var cooldown: int
## 当前冷却时间
@export_storage var current_cooldown : int = 0
## 技能释放时间（秒）
@export var cast_time: float
## 技能是否显示在UI中
@export var is_show : bool = true
## 技能释放时播放的音效
@export var sound_effect: StringName
## 技能释放时播放的动画
@export var animation: StringName
## 是否正处在冷却状态
var is_cooldown: bool:
	get:
		return current_cooldown > 0
