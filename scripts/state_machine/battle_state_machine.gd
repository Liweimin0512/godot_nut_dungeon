extends BaseStateMachine
class_name BattleStateMachine

## 战斗状态机

func _ready() -> void:
	add_state("init", InitState.new())
	add_state("turn_prepare", TurnPrepareState.new())
	add_state("turn_start", TurnStartState.new())
	add_state("action_select", ActionSelectState.new())
	add_state("action_execute", ActionExecuteState.new())
	add_state("turn_end", TurnEndState.new())
	add_state("battle_end", BattleEndState.new())

## 初始化状态
class InitState:
	extends BaseState
	
	func _enter(msg: Dictionary = {}) -> void:
		var battle_scene := agent as BattleScene
		battle_scene.initialize_battle(msg)
		switch_to("turn_prepare")

## 回合准备状态
class TurnPrepareState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		var battle_scene := agent as BattleScene
		battle_scene.prepare_turn()
		switch_to("turn_start")

## 回合开始状态
class TurnStartState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		var battle_scene := agent as BattleScene
		battle_scene.start_turn()
		switch_to("action_select")

## 行动选择状态
class ActionSelectState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		var battle_scene := agent as BattleScene
		if battle_scene.has_next_action_unit():
			battle_scene.show_action_selection()
		else:
			switch_to("turn_end")
	
	func _on_action_selected(action: Dictionary) -> void:
		switch_to("action_execute", action)

## 行动执行状态
class ActionExecuteState:
	extends BaseState
	
	func _enter(msg: Dictionary = {}) -> void:
		var battle_scene := agent as BattleScene
		await battle_scene.execute_action(msg)
		if battle_scene.if_battle_ended():
			switch_to("battle_end", {
				"result": battle_scene.get_battle_result()
			})
		else:
			switch_to("action_select")

## 回合结束状态
class TurnEndState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		var battle_scene := agent as BattleScene
		battle_scene.end_turn()
		
		if battle_scene.is_max_turns_reached():
			switch_to("battle_end", {
				# 结算结果, 超出回合数战斗失败
				"result": "defeat"
			})
		else:
			switch_to("turn_prepare")

## 战斗结束状态
class BattleEndState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		var battle_scene := agent as BattleScene
		battle_scene.end_battle(_msg["result"])