extends BaseStateMachine
class_name GameStateMachine

enum GAME_STATE_TYPE{
	LAUNCH,
	INIT,
	MENU,
	GAME,
}

func _ready() -> void:
	add_state(GAME_STATE_TYPE.LAUNCH, LaunchState.new(self))
	add_state(GAME_STATE_TYPE.INIT, InitState.new(self))
	add_state(GAME_STATE_TYPE.MENU, MenuState.new(self))
	add_state(GAME_STATE_TYPE.GAME, GameState.new(self))
	launch(GAME_STATE_TYPE.LAUNCH)

class LaunchState:
	extends BaseState
	
	func enter(_msg: Dictionary = {}):
		transition_to(GAME_STATE_TYPE.INIT)

class InitState:
	extends BaseState
	
	var _datatable_state : Dictionary[StringName, bool]

	func enter(_msg : Dictionary = {}):
		DatatableManager.load_completed.connect(_on_datatable_load_completed)
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
		transition_to(GAME_STATE_TYPE.MENU)

class MenuState:
	extends BaseState
	
	func enter(_msg: Dictionary = {}) -> void:
		print("进入 menu_state 状态！")
		transition_to(GAME_STATE_TYPE.GAME)

class GameState:
	extends BaseState

	func enter(_msg: Dictionary = {}) -> void:
		print("进入 game_state 状态！")
		agent.play_game()
