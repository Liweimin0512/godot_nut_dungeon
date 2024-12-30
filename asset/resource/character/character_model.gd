extends Resource
class_name CharacterModel

## 角色数据模型

## 角色名
@export var character_name : StringName = ""
## 技能属性集合
@export var ability_attributes: Array[AbilityAttribute]
## 技能集合
@export var abilities : Array[Ability]
## 技能消耗集合
@export var ability_resources : Array[AbilityResource]
