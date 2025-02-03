extends Node2D

const GAME_SCENE = preload("res://scenes/core/game_scene.tscn")

@export var table_types : TableTypes = preload("res://resources/data/table_types.tres")

## 异步批量加载json文件
func load_json_batch_async(load_complete_callback: Callable, load_progress_callback: Callable) -> void:
	JsonLoader.load_json_batch(table_types.json_paths, load_complete_callback, load_progress_callback)

## 批量加载csv文件
func load_datatables() -> void:
	DatatableManager.load_data_models(table_types.table_models)

## 开始游戏
func play_game() -> void:
	var game_scene = GAME_SCENE.instantiate()
	add_child(game_scene)
