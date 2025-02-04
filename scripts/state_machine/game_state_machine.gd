extends BaseStateMachine

func _ready() -> void:
	add_state("launch", LaunchState.new(self))
	add_state("init", InitState.new(self))
	add_state("change_scene", ChangeSceneState.new(self))
	add_state("menu", MenuState.new(self))
	add_state("game", GameState.new(self))

## 启动流程
class LaunchState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}):
		print("进入 launch 状态！")
		switch_to("init")

## 初始化流程
class InitState:
	extends BaseState

	func _ready() -> void:
		agent.initialized.connect(_on_initialized)

	func _enter(_msg : Dictionary = {}) -> void:
		print("进入 init_state 状态！")
		agent.initialize()

	func _exit() -> void:
		print("退出 init_state 状态！")

	func _on_initialized() -> void:
		print("初始化完成！")
		switch_to("change_scene", {"scene": "game"})

## 切换场景
class ChangeSceneState:
	extends BaseState

	var scene_name : StringName

	func _ready() -> void:
		agent.scene_changed.connect(_on_scene_changed)

	func _enter(msg: Dictionary = {}) -> void:
		print("进入 change_scene_state 状态！")
		scene_name = msg.get("scene", &"menu")
		agent.change_scene(scene_name)

	func _on_scene_changed(old_scene: Node, new_scene: Node) -> void:
		print("切换场景完成，旧场景：", old_scene, ", 新场景：", new_scene)
		switch_to(scene_name)

## 菜单状态
class MenuState:
	extends BaseState
	
	func _enter(_msg: Dictionary = {}) -> void:
		print("进入 menu_state 状态！")
		agent.show_menu()
		# switch_to("game")

	func _exit() -> void:
		print("退出 menu_state 状态！")

## 游戏状态
class GameState:
	extends BaseState

	func _enter(_msg: Dictionary = {}) -> void:
		print("进入 game_state 状态！")
		agent.play_game()
