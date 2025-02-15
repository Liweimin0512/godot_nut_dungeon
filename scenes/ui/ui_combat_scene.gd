extends Control
class_name UICombatScene

@onready var hero_info: PanelContainer = %HeroInfo
@onready var enemy_info: PanelContainer = %EnemyInfo
@onready var turn_status: TurnStatus = %TurnStatus
@onready var ui_scene_component: UISceneComponent = $UISceneComponent

var _combat_manager : CombatManager

func _ready() -> void:
	pass

func setup(combat_manager: CombatManager) -> void:
	_combat_manager = combat_manager
	
	CombatSystem.combat_started.subscribe(_on_combat_started)
	CombatSystem.combat_turn_started.subscribe(_on_turn_started)
	CombatSystem.combat_action_started.subscribe(_on_action_ready)
	CombatSystem.combat_turn_ended.subscribe(_on_turn_ended)
	#TODO
	#CombatSystem.combat_finished.subscribe(_on_combat_finished)
	#CombatSystem.combat_defeated.subscribe(_on_combat_defeated)
	CombatSystem.combat_ended.subscribe(_on_combat_ended)

	ui_scene_component.update({
		"combat_manager": combat_manager
	})

## 战斗开始回调
func _on_combat_started() -> void:
	# 处理战斗开始的表现效果
	pass

## 回合准备回调
func _on_turn_prepared() -> void:
	pass

## 回合开始回调
func _on_turn_started(_combat: CombatManager) -> void:
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
