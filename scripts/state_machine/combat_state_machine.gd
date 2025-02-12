extends BaseStateMachine
class_name CombatStateMachine

## 战斗状态机，负责管理战斗流程的状态转换
## 具体的战斗逻辑由CombatManager实现

func _ready() -> void:
	## 初始化
	add_state("init", InitState.new())
	## 战斗开始
	add_state("combat_start", CombatStartState.new())
	## 回合开始
	add_state("turn_start", TurnStartState.new())
	## 动作选择
	add_state("action_select", ActionSelectState.new())
	## 动作执行
	add_state("action_execute", ActionExecuteState.new())
	## 回合结束
	add_state("turn_end", TurnEndState.new())
	## 战斗结束
	add_state("combat_end", CombatEndState.new())

## 初始化状态
class InitState:
	extends BaseState
	
	func _enter(msg: Dictionary = {}) -> void:
		print("进入初始化状态！")
		var combat_manager := agent as CombatManager
		var combat_info : CombatModel = msg.get("combat_info", null)
		if not combat_info:
			push_error("初始化战斗状态机时缺少战斗数据！")
			return
		
		combat_manager.initialize(combat_info)
		switch_to("combat_start")

## 战斗开始状态
class CombatStartState:
	extends BaseState

	func _enter(_msg: Dictionary = {}) -> void:
		print("进入战斗开始状态！")
		var combat_manager := agent as CombatManager
		# 由战斗管理器处理战斗开始逻辑
		combat_manager.start_combat()
		switch_to("turn_start")

## 回合开始状态
class TurnStartState:
	extends BaseState
	
	func _ready() -> void:
		var combat_manager := agent as CombatManager
		combat_manager.turn_prepare_ended.connect(_on_turn_prepare_ended)

	func _enter(_msg: Dictionary = {}) -> void:
		print("进入回合准备状态！")
		var combat_manager := agent as CombatManager
		# 由战斗管理器处理回合准备逻辑
		combat_manager.turn_prepare()

	func _on_turn_prepare_ended() -> void:
		if state_machine.current_state != self:
			return
		print("回合准备结束！")
		switch_to("action_select")

## 动作选择状态
class ActionSelectState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		print("进入动作选择状态！")
		var combat_manager := agent as CombatManager
		combat_manager.action_select()

## 动作执行状态
class ActionExecuteState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		print("进入动作执行状态！")
		var combat_manager := agent as CombatManager
		# 由战斗管理器处理动作执行逻辑
		combat_manager.execute_next_action()
		switch_to("action_select")

## 回合结束状态
class TurnEndState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		print("进入回合结束状态！")
		var combat_manager := agent as CombatManager
		# 由战斗管理器处理回合结束逻辑
		combat_manager.end_turn()
		
		if combat_manager.check_victory_condition():
			combat_manager.combat_victory()
			switch_to("battle_end")
		elif combat_manager.check_defeat_condition():
			combat_manager.combat_defeat()
			switch_to("battle_end")
		else:
			switch_to("turn_prepare")

## 战斗结束状态
class CombatEndState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		print("进入战斗结束状态！")
		var combat_manager := agent as CombatManager
		# 由战斗管理器处理战斗结束逻辑
		combat_manager.combat_end()
