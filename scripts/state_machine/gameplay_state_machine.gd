extends BaseStateMachine
class_name GameplayStateMachine

func _ready() -> void:
	add_state("explore", ExploreState.new(self))
	add_state("battle", BattleState.new(self))
	add_state("dialogue", DialogueState.new(self))
	add_state("menu", MenuState.new(self))

## 探索状态
class ExploreState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		print("进入探索状态")
		# TODO: 启用玩家控制器
		# TODO: 启用地图交互
	
	func _exit() -> void:
		print("退出探索状态")
		# TODO: 禁用玩家控制器
		# TODO: 禁用地图交互

## 战斗状态
class BattleState:
	extends BaseState
	
	var _battle_scene = preload("res://scenes/battle/battle_scene.tscn")
	var _current_battle: BattleScene
	
	func _enter(msg: Dictionary = {}) -> void:
		print("进入战斗状态")
		# 创建战斗场景
		_current_battle = _battle_scene.instantiate()
		agent.add_child(_current_battle)
		_current_battle.battle_finished.connect(_on_battle_finished)
		_current_battle.start_battle(msg)
	
	func _exit() -> void:
		print("退出战斗状态")
		if _current_battle:
			_current_battle.queue_free()
			_current_battle = null
	
	func _on_battle_finished(result: Dictionary) -> void:
		print("战斗结束：", result)
		switch_to("explore")

## 对话状态
class DialogueState:
	extends BaseState
	
	func _enter(msg: Dictionary = {}) -> void:
		print("进入对话状态")
		# TODO: 显示对话UI
		# TODO: 加载对话内容
	
	func _exit() -> void:
		print("退出对话状态")
		# TODO: 隐藏对话UI

## 菜单状态
class MenuState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		print("进入菜单状态")
		# TODO: 显示游戏菜单
	
	func _exit() -> void:
		print("退出菜单状态")
		# TODO: 隐藏游戏菜单
