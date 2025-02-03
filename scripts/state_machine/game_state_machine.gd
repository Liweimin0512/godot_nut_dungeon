extends BaseStateMachine
class_name GameStateMachine

func _ready() -> void:
	add_state("launch", LaunchState.new(self))
	add_state("init", InitState.new(self))
	add_state("menu", MenuState.new(self))
	add_state("game", GameState.new(self))

class LaunchState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}):
		switch_to("init")

class InitState:
	extends BaseState
	
	var _datatable_state : Dictionary[StringName, bool]

	func _enter(_msg : Dictionary = {}) -> void:
		DataManager.load_completed.connect(_on_datatable_load_completed)
		for model : ModelType in agent.table_types.table_models:
			for table : TableType in model.tables:
				_datatable_state[table.table_name] = false
		agent.load_json_batch_async(_on_load_json_complete, _on_load_json_progress)

	func _on_load_json_progress(current: int, total: int) -> void:
		print("JSON加载进度: {0}/{1}".format([current, total]))

	func _on_load_json_complete(_results: Dictionary) -> void:
		agent.load_datatables()

	func _on_datatable_load_completed(datatable_name : String) -> void:
		print("加载datatable {0} 完成！".format([datatable_name]))
		_datatable_state[datatable_name] = true
		for state in _datatable_state.values():
			if state != true:
				return
		switch_to("menu")

class MenuState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		print("进入 menu_state 状态！")
		switch_to("game")

class GameState:
	extends BaseState

	func _enter(_msg: Dictionary = {}) -> void:
		print("进入 game_state 状态！")
		agent.play_game()
