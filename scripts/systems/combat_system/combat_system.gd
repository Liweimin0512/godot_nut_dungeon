extends Node

## 战斗相关配置
const DEFAULT_COMBAT_CONFIG := {
	"max_turn_count": 99,
	"is_auto": true,
	"is_real_time": true
}

## 当前活跃的战斗实例
var active_combat: Combat

## 战斗相关信号
signal combat_created(combat: Combat)
signal combat_started(combat: Combat)
signal combat_ended(combat: Combat)

## 初始化战斗系统
func initialize() -> void:
	# 初始化战斗相关的子系统
	# 例如：技能系统、效果系统、AI系统等
	_init_subsystems()

## 创建新的战斗实例
func create_combat(
		player_combats: Array[CombatComponent],
		enemy_combats: Array[CombatComponent],
		combat_model: CombatModel) -> Combat:
	# 如果已有活跃战斗，先结束它
	if active_combat:
		end_combat()
	
	# 创建新的战斗实例
	active_combat = Combat.new()
	# 连接信号
	_connect_combat_signals(active_combat)
	active_combat.player_combats = player_combats
	active_combat.enemy_combats = enemy_combats
	active_combat.initialize(combat_model)
	
	combat_created.emit(active_combat)
	return active_combat

## 结束当前战斗
func end_combat() -> void:
	if active_combat:
		active_combat.queue_free()
		active_combat = null

## 获取当前战斗实例
func get_active_combat() -> Combat:
	return active_combat

## 注册战斗效果
## TODO 实现
func register_effect(_effect_id: String, _effect_script: String) -> void:
	# EffectNodeFactory.register_node_type(effect_id, effect_script)
	pass

### 加载战斗AI
#func load_combat_ai(ai_id: String) -> CombatAI:
	## TODO: 实现AI加载
	#pass
#
### 获取战斗统计
#func get_combat_statistics() -> Dictionary:
	## TODO: 实现战斗统计
	#pass

# region 私有方法

func _init_subsystems() -> void:
	# 初始化效果系统
	#EffectNodeFactory.initialize()
	# TODO: 初始化其他子系统
	pass

func _connect_combat_signals(combat: Combat) -> void:
	combat.combat_started.connect(
		func(): combat_started.emit(combat)
	)
	combat.combat_ended.connect(
		func(): combat_ended.emit(combat)
	)
# endregion
