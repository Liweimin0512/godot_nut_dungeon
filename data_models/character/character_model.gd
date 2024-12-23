extends Resource
class_name CharacterModel

## 角色数据模型

## 角色名
@export var character_name : StringName = ""
## 所属阵营
@export var camp : CombatDefinition.COMBAT_CAMP_TYPE = CombatDefinition.COMBAT_CAMP_TYPE.NONE
## 最大生命值
@export var max_health : float = 100
## 攻击力
@export var attack_power : float = 10.0
## 防御力
@export var defense_power : float = 5
## 出手速度
@export var speed : float = 1
