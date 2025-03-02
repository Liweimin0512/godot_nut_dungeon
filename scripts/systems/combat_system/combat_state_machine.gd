extends BaseStateMachine
class_name CombatStateMachine

## 战斗状态机，负责管理战斗流程的状态转换
## 主要状态：
## 1. 初始化状态：设置战斗初始条件
## 2. 回合开始状态：准备新回合
## 3. 回合执行状态：处理单位行动
## 4. 回合结束状态：清理回合效果
## 5. 战斗结束状态：结算战斗结果

# 战斗系统引用
var combat_system: Node:
	get:
		return agent

func _ready() -> void:
	is_debug = true
	## 战斗启动
	add_state("combat_startup", CombatStartupState.new())
	## 战斗开始
	add_state("combat_start", CombatStartState.new())
	## 回合开始
	add_state("turn_start", TurnStartState.new())
	## 行动准备
	add_state("action_prepare", ActionPrepareState.new())
	## 行动执行
	add_state("action_execute", ActionExecuteState.new())
	## 回合结束
	add_state("turn_end", TurnEndState.new())
	## 战斗结束
	add_state("combat_end", CombatEndState.new())


class CombatStartupState:
	extends BaseState

	func _enter(_msg: Dictionary = {}) -> void:
		switch_to("combat_start")

## 战斗开始状态
class CombatStartState:
	extends BaseState

	func _enter(_msg: Dictionary = {}) -> void:
		CombatSystem.combat_started.subscribe(_on_combat_started)
		CombatSystem.start_combat()
	
	func _exit() -> void:
		CombatSystem.combat_started.unsubscribe(_on_combat_started)

	func _on_combat_started() -> void:
		if state_machine.current_state != self:
			return
		await CombatSystem.get_tree().create_timer(0.5).timeout
		switch_to("turn_start")

## 回合开始状态
class TurnStartState:
	extends BaseState

	func _enter(_msg: Dictionary = {}) -> void:
		CombatSystem.combat_turn_started.subscribe(_on_turn_started)
		CombatSystem.start_turn()

	func _exit() -> void:
		CombatSystem.combat_turn_started.unsubscribe(_on_turn_started)

	## 回合开始
	func _on_turn_started() -> void:
		if state_machine.current_state != self:
			return
		await CombatSystem.get_tree().create_timer(0.5).timeout
		switch_to("action_prepare")

## 行动准备
class ActionPrepareState:
	extends BaseState

	func _enter(_msg: Dictionary = {}) -> void:
		CombatSystem.start_action()
		if CombatSystem.is_auto_action():
			CombatSystem.start_auto_action()
			await CombatSystem.get_tree().create_timer(0.5).timeout
			switch_to("action_execute")
		else:
			CombatSystem.action_target_selected.subscribe(_on_action_target_selected)
			CombatSystem.start_manual_action()

	func _exit() -> void:
		if CombatSystem.is_auto_action():
			CombatSystem.action_target_selected.unsubscribe(_on_action_target_selected)

	func _on_action_target_selected() -> void:
		if state_machine.current_state != self:
			return
		switch_to("action_execute")

## 行动执行
class ActionExecuteState:
	extends BaseState

	func _enter(_msg: Dictionary = {}) -> void:
		CombatSystem.combat_action_executed.subscribe(_on_combat_action_executed)
		CombatSystem.execute_action()
	
	func _exit() -> void:
		CombatSystem.combat_action_executed.unsubscribe(_on_combat_action_executed)
		CombatSystem.end_action()

	func _on_combat_action_executed() -> void:
		if state_machine.current_state != self:
			return
		if CombatSystem.check_victory_condition():
			switch_to("combat_end")
		elif CombatSystem.check_defeat_condition():
			switch_to("combat_end")
		elif CombatSystem.is_all_units_executed():
			switch_to("turn_end")
		else:
			switch_to("action_prepare")

## 回合结束状态
class TurnEndState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		CombatSystem.combat_turn_ended.subscribe(_on_turn_ended)
		CombatSystem.end_turn()

	func _exit() -> void:
		CombatSystem.combat_turn_ended.unsubscribe(_on_turn_ended)
	
	func _on_turn_ended() -> void:
		if state_machine.current_state != self:
			return
		if CombatSystem.is_max_turn_count_reached():
			CombatSystem.combat_defeat()
			switch_to("combat_end")
		else:
			switch_to("turn_start")

## 战斗结束状态
class CombatEndState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		print("进入战斗结束状态！")
		# 由战斗管理器处理战斗结束逻辑
		CombatSystem.end_combat()
