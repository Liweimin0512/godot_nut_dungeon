extends Resource
class_name CharacterModel

## 角色数据模型

## 角色名
@export var character_name : StringName = ""
## 角色头像
@export var character_icon : Texture2D
## 技能属性集合
@export var ability_attributes: Array[AbilityAttribute]
## 技能集合
@export var abilities : Array[Ability]
## 技能消耗集合
@export var ability_resources : Array[AbilityResource]
## 动画库
@export var animation_library : AnimationLibrary
## 精灵位置
@export var sprite_position : Vector2
## 所属阵营
@export_storage var camp : CombatDefinition.COMBAT_CAMP_TYPE = CombatDefinition.COMBAT_CAMP_TYPE.PLAYER

var ability_resource_script: Dictionary[StringName, Script] = {
	"enery": preload("res://scripts/systems/ability_system/ability_cost_resource/enery_resource.gd"), 
	"health": preload("res://scripts/systems/ability_system/ability_cost_resource/health_resource.gd"), 
	"mana": preload("res://scripts/systems/ability_system/ability_cost_resource/mana_resource.gd"), 
	"rage": preload("res://scripts/systems/ability_system/ability_cost_resource/rage_resource.gd")
}

func _init_from_data(data: Dictionary) -> void:
	ability_attributes = DataManager.get_data_model("ability_attribute_set", data.ability_attributes).attributes
	for ability_id in data.abilities:
		var ability : TurnBasedSkillAbility = DataManager.get_data_model("skill_ability", ability_id)
		if ability:
			abilities.append(ability)
		else:
			printerr("can not found ability : {0}".format([ability_id]))
	for ability_res_id in data.ability_resources:
		var script : Script = ability_resource_script.get(ability_res_id, null)
		if script:
			ability_resources.append(script.new())
		else:
			printerr("can not found ability resource script: {0}".format([ability_res_id]))
