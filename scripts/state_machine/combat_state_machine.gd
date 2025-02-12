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
	## 回合执行
	add_state("turn_execute", TurnExecuteState.new())
	## 回合结束
	add_state("turn_end", TurnEndState.new())
	## 战斗结束
	add_state("combat_end", CombatEndState.new())

## 初始化状态
class InitState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		print("进入初始化状态！")
		var combat_manager := agent as CombatManager
		combat_manager.initialize()
		switch_to("combat_start")

## 战斗开始状态
class CombatStartState:
	extends BaseState

	func _enter(_msg: Dictionary = {}) -> void:
		CombatSystem.combat_started.subscribe(_on_combat_started)
		print("进入战斗开始状态！")
		var combat_manager := agent as CombatManager
		# 由战斗管理器处理战斗开始逻辑
		combat_manager.start_combat()
		switch_to("turn_start")

	func _exit() -> void:
		CombatSystem.combat_started.unsubscribe(_on_combat_started)
		print("退出战斗开始状态！")

	func _on_combat_started() -> void:
		if state_machine.current_state != self:
			return
		switch_to("turn_start")

## 回合开始状态
class TurnStartState:
	extends BaseState

	func _enter(_msg: Dictionary = {}) -> void:
		print("进入回合开始状态！")
		CombatSystem.turn_started.subscribe(_on_turn_started)
		var combat_manager := agent as CombatManager
		combat_manager.turn_start()

	func _exit() -> void:
		CombatSystem.turn_started.unsubscribe(_on_turn_started)
		print("退出回合开始状态！")

	## 回合开始
	func _on_turn_started() -> void:
		if state_machine.current_state != self:
			return
		switch_to("turn_execute")

## 回合执行状态
class TurnExecuteState:
	extends BaseStateMachine

	func _ready() -> void:
		print("进入回合执行状态！")
		add_state("action_start", ActionStartState.new())
		add_state("action_execute", ActionExecuteState.new())
		add_state("action_end", ActionEndState.new())

	func _enter(_msg: Dictionary = {}) -> void:
		print("进入回合执行状态！")
		switch("action_start")

	func _exit() -> void:
		print("退出回合执行状态！")

	class ActionStartState:
		extends BaseState

		func _enter(_msg: Dictionary = {}) -> void:
			print("进入动作准备状态！")
			CoreSystem.action_started.subscribe(_on_action_started)
			var combat_manager := agent as CombatManager
			combat_manager.action_start()

		func _exit() -> void:
			print("退出动作准备状态！")
			CoreSystem.action_started.unsubscribe(_on_action_started)
		
		func _on_action_started() -> void:
			if state_machine.current_state != self:
				return
			switch_to("action_execute")
	
	class ActionExecuteState:
		extends BaseState
		
		func _enter(_msg: Dictionary = {}) -> void:
			print("进入动作执行状态！")
			CoreSystem.action_executed.subscribe(_on_action_executed)
			var combat_manager := agent as CombatManager
			# 由战斗管理器处理动作执行逻辑
			combat_manager.action_execute()

		func _exit() -> void:
			print("退出动作执行状态！")
			CoreSystem.action_executed.unsubscribe(_on_action_executed)

		func _on_action_executed() -> void:
			if state_machine.current_state != self:
				return
			switch_to("action_end")

	class ActionEndState:
		extends BaseState
		
		func _enter(_msg: Dictionary = {}) -> void:
			print("进入动作结束状态！")
			CoreSystem.action_ended.subscribe(_on_action_ended)
			var combat_manager := agent as CombatManager
			combat_manager.action_end()

		func _exit() -> void:
			CoreSystem.action_ended.unsubscribe(_on_action_ended)
			print("退出动作结束状态！")
		
		func _on_action_ended() -> void:
			var combat_manager := agent as CombatManager
			if combat_manager.check_victory_condition():
				# 胜利条件判断
				combat_manager.combat_victory()
				state_machine.switch_to("combat_end")
			elif combat_manager.check_defeat_condition():
				# 失败条件判断
				combat_manager.combat_defeat()
				state_machine.switch_to("combat_end")
			elif combat_manager.is_all_units_executed():
				# 所有单位执行完毕，则回合结束
				state_machine.switch_to("turn_end")
			else:
				# 否则进入动作开始状态
				switch_to("action_start")

## 回合结束状态
class TurnEndState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		print("进入回合结束状态！")
		CombatSystem.turn_ended.subscribe(_on_turn_ended)
		var combat_manager := agent as CombatManager
		# 由战斗管理器处理回合结束逻辑
		combat_manager.end_turn()
		if combat_manager.is_max_turn_count_reached():
			switch_to("combat_end")
		else:
			switch_to("turn_start")

	func _exit() -> void:
		CombatSystem.turn_ended.unsubscribe(_on_turn_ended)
		print("退出回合结束状态！")
	
	func _on_turn_ended() -> void:
		if state_machine.current_state != self:
			return
		var combat_manager := agent as CombatManager
		if combat_manager.is_all_units_executed():
			switch_to("combat_end")
		else:
			switch_to("turn_start")

## 战斗结束状态
class CombatEndState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		print("进入战斗结束状态！")
		var combat_manager := agent as CombatManager
		# 由战斗管理器处理战斗结束逻辑
		combat_manager.combat_end()
