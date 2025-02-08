extends Node

## 英雄单位字典，key为英雄ID，value为英雄实例
var heroes: Dictionary = {}
## 当前队伍中的英雄
var active_party: Array[Character] = []
## 最大队伍人数
const MAX_PARTY_SIZE = 4

## 初始化系统
func initialize() -> void:
	# 在开发阶段，直接加载测试英雄
	_load_test_heroes()

## 添加英雄到队伍
func add_to_party(hero_id: String) -> bool:
	if active_party.size() >= MAX_PARTY_SIZE:
		return false
	
	var hero = heroes.get(hero_id)
	if not hero:
		return false
		
	active_party.append(hero)
	return true

## 从队伍移除英雄
func remove_from_party(hero_id: String) -> void:
	var hero = heroes.get(hero_id)
	if hero:
		active_party.erase(hero)

## 获取当前队伍
func get_active_party() -> Array[Character]:
	return active_party

## 清空当前队伍
func clear_party() -> void:
	active_party.clear()

## 获取所有可用英雄
func get_available_heroes() -> Array[Character]:
	return heroes.values()

## 开发阶段：加载测试英雄
func _load_test_heroes() -> void:
	var test_heroes = [
		"crystal_mauler",
		"leaf_ranger",
		"water_priestess",
		"wizard"
	]
	
	for hero_id in test_heroes:
		var hero_model = DataManager.get_data_model("character", hero_id)
		if hero_model:
			var hero = _create_hero(hero_model)
			heroes[hero_id] = hero
			# 开发阶段：自动添加到队伍
			add_to_party(hero_id)

## 创建英雄实例
func _create_hero(hero_model: CharacterModel) -> Character:
	var hero = preload("res://scenes/character/character.tscn").instantiate()
	hero.setup(hero_model)
	return hero
