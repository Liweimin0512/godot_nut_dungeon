extends Resource
class_name CombatModel

## 战斗数据模型

## 最大回合数
@export var max_turn_count: int = 99
## 敌人models
@export var enemies : Array[CharacterModel]
## 是否自动开始
@export var is_auto : bool = true
## 是否实时
@export var is_real_time : bool = true
