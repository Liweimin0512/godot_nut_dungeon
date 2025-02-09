extends Control
class_name UICombatScene

@onready var hero_info: PanelContainer = %HeroInfo
@onready var enemy_info: PanelContainer = %EnemyInfo
@onready var turn_status: PanelContainer = %TurnStatus

var _combat_manager : CombatManager

func _ready() -> void:
	pass

func setup(combat_manager: CombatManager) -> void:
	_combat_manager = combat_manager
	
	_combat_manager.combat_started.connect(_on_combat_started)
	_combat_manager.turn_prepared.connect(_on_turn_prepared)
	_combat_manager.turn_started.connect(_on_turn_started)
	_combat_manager.turn_ended.connect(_on_turn_ended)
	_combat_manager.combat_finished.connect(_on_combat_finished)
	_combat_manager.combat_defeated.connect(_on_combat_defeated)
	_combat_manager.combat_ended.connect(_on_combat_ended)
	_combat_manager.action_ready.connect(_on_action_ready)



## 战斗开始回调
func _on_combat_started() -> void:
	# 处理战斗开始的表现效果
	pass

## 回合准备回调
func _on_turn_prepared() -> void:
	pass

## 回合开始回调
func _on_turn_started(_turn_count: int) -> void:
	pass

## 回合结束回调
func _on_turn_ended() -> void:
	# 处理回合结束的表现效果
	pass

## 战斗胜利回调
func _on_combat_finished() -> void:
	# 显示胜利界面
	pass

## 战斗失败回调
func _on_combat_defeated() -> void:
	# 显示失败界面
	pass

## 战斗结束回调
func _on_combat_ended() -> void:
	# 处理战斗结束的清理工作
	pass

## 行动准备回调
func _on_action_ready(_unit: CombatComponent) -> void:
	# 显示行动选择UI
	pass
