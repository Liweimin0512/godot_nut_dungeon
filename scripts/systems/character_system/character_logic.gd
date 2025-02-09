extends EntityLogic
class_name CharacterLogic

## 角色逻辑类
## 负责管理角色的逻辑组件和数据

## 角色配置更新信号
signal character_config_updated(config: CharacterModel)

## 角色配置
var character_config: CharacterModel:
	get:
		return character_config
	set(value):
		if character_config == value:
			return
		character_config = value
		character_config_updated.emit(value)

## 角色阵营
var character_camp: CombatDefinition.COMBAT_CAMP_TYPE = CombatDefinition.COMBAT_CAMP_TYPE.PLAYER:
	get:
		return character_camp
	set(value):
		if character_camp == value:
			return
		character_camp = value
		_on_camp_changed(value)

var ability_attribute_component: AbilityAttributeComponent
var ability_component: AbilityComponent
var ability_resource_component: AbilityResourceComponent
var combat_component: CombatComponent

## 初始化
func _initialize(data: Dictionary = {}) -> void:
	# 设置角色配置
	if not data.has("character_config"):
		push_error("character config is null")
		return
	character_config = data["character_config"]
	
	# 设置角色阵营
	if not data.has("character_camp"):
		push_error("character camp is null")
		return
	character_camp = data["character_camp"]

	ability_attribute_component = add_component("ability_attribute_component", AbilityAttributeComponent.new())
	ability_component = add_component("ability_component", AbilityComponent.new())
	ability_resource_component = add_component("ability_resource_component", AbilityResourceComponent.new())
	combat_component = add_component("combat_component", CombatComponent.new())
	_update_components()

## 更新角色数据
func update_character(data: Dictionary) -> void:
	if data.has("character_config"):
		character_config = data["character_config"]
	
	if data.has("character_camp"):
		character_camp = data["character_camp"]
	
	# 更新组件数据
	_update_components()

## 阵营改变回调
func _on_camp_changed(new_camp: CombatDefinition.COMBAT_CAMP_TYPE) -> void:
	# 通知组件阵营改变
	for component in _components.values():
		if component.has_method("_on_camp_changed"):
			component._on_camp_changed(new_camp)

## 更新组件数据
func _update_components() -> void:
	update_component("ability_attribute_component", {"ability_attributes": character_config.ability_attributes})
	update_component("ability_component", {
		"abilities": character_config.abilities,
		"ability_context": {},
	})
	update_component("ability_resource_component", {
		"ability_resources": character_config.ability_resources,
		"ability_component": get_component("ability_component"),
		"ability_attribute_component": get_component("ability_attribute_component"),
	})
	update_component("combat_component", {
		"combat_camp": character_camp,
		"ability_component": get_component("ability_component"),
		"ability_resource_component": get_component("ability_resource_component"),
		"ability_attribute_component": get_component("ability_attribute_component"),
	})
