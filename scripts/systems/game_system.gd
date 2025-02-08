extends Node

## 功能模块管理器

var _logger: CoreSystem.Logger:
	get:
		return CoreSystem.logger

signal initialized(success: bool)

## 初始化
func initialize() -> void:
	# 初始化模块链
	_init_core_system(func(): _init_framework_system())
	initialized.emit()

## 初始化核心系统
func _init_core_system(complete_callback: Callable) -> void:
	_logger.info("Initializing CoreSystem...")
	# 判断CoreSystem单例是否存在
	if not Engine.has_singleton("CoreSystem"):
		push_error("CoreSystem singleton does not exist")
		return
	if complete_callback.is_valid():
		complete_callback.call()
	_logger.info("CoreSystem initialized")

## 初始化框架系统
func _init_framework_system() -> void:
	pass

## 初始化功能系统
func _init_function_system() -> void:
	pass

## 初始化业务系统
func _init_business_system() -> void:
	pass

## 初始化游戏业务数据
func _init_business_data() -> bool:
	# TODO: 初始化游戏业务数据
	# 例如: 加载存档、初始化游戏进度等
	return false
