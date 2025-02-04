extends BaseStateMachine
class_name BattleStateMachine

func _ready() -> void:
	add_state("init", InitState.new(self))
	add_state("turn_prepare", TurnPrepareState.new(self))
	add_state("turn_start", TurnStartState.new(self))
	add_state("action_select", ActionSelectState.new(self))
	add_state("action_execute", ActionExecuteState.new(self))
	add_state("turn_end", TurnEndState.new(self))
	add_state("battle_end", BattleEndState.new(self))

## 初始化状态
class InitState:
	extends BaseState
	
	func _enter(msg: Dictionary = {}) -> void:
		print("战斗初始化")
		# TODO: 初始化战斗场景
		# TODO: 创建战斗单位
		# TODO: 播放开场动画
		switch_to("turn_prepare", msg)

## 回合准备状态
class TurnPrepareState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		print("回合准备")
		# TODO: 计算行动顺序
		# TODO: 获取下一个行动单位
		switch_to("turn_start")

## 回合开始状态
class TurnStartState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		print("回合开始")
		# TODO: 触发回合开始效果
		switch_to("action_select")

## 行动选择状态
class ActionSelectState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		print("选择行动")
		# TODO: 显示行动菜单
		# TODO: 等待玩家选择行动
	
	func _on_action_selected(action: Dictionary) -> void:
		switch_to("action_execute", action)

## 行动执行状态
class ActionExecuteState:
	extends BaseState
	
	func _enter(msg: Dictionary = {}) -> void:
		print("执行行动")
		# TODO: 执行选择的行动
		# TODO: 播放动画和效果
		# TODO: 检查战斗是否结束
		if _is_battle_end():
			switch_to("battle_end")
		else:
			switch_to("turn_end")
	
	func _is_battle_end() -> bool:
		# TODO: 检查战斗结束条件
		return false

## 回合结束状态
class TurnEndState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		print("回合结束")
		# TODO: 触发回合结束效果
		switch_to("turn_prepare")

## 战斗结束状态
class BattleEndState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		print("战斗结束")
		# TODO: 结算战斗结果
		# TODO: 显示战斗结算UI
		# TODO: 通知游戏场景战斗结束
		agent.battle_finished.emit()
