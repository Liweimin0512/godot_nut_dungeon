extends Node
class_name CombatComponent

## 最大生命值
@export var max_health : float = 100
## 当前生命值
@export_storage var current_health : float = 100:
	set(value):
		current_health = value
		current_health_changed.emit(current_health)
## 攻击力
@export var attack_power : float = 10.0
## 防御力
@export var defense_power : float = 5
## 出手速度
@export var speed : float = 1
## 所属阵营
@export var camp : CombatDefinition.COMBAT_CAMP_TYPE = CombatDefinition.COMBAT_CAMP_TYPE.NONE
## 是否为存货单位
var is_alive : bool :
	get:
		return current_health > 0
## 当前战斗，为空则表示不是在战斗状态
var _current_combat: Combat

signal hited(target: Character)
signal hurted(damage: int)
signal current_health_changed(value: float)
signal died
signal combat_started
signal combat_ended

func _ready() -> void:
	current_health = max_health

## 战斗开始
func combat_start(combat: Combat) -> void:
	print(self, "战斗开始！")
	_current_combat = combat
	combat_started.emit()

## 回合开始
func turn_start() -> void:
	if not _current_combat: return
	print(self, "====== 回合开始")
	var target := _current_combat.get_random_enemy(self)
	if _current_combat.is_real_time:
		await get_tree().create_timer(0.5).timeout
	if not target: return
	await hit(target)

## 回合结束
func turn_end() -> void:
	if not _current_combat: return
	print(self, "====== 回合结束")

## 战斗结束
func combat_end() -> void:
	print(self, " 战斗结束", "剩余血量: ", current_health)
	_current_combat = null
	combat_ended.emit()

## 攻击
func hit(target: CombatComponent) -> void:
	if not target: return
	hited.emit(target)
	if _current_combat.is_real_time:
		await get_tree().create_timer(0.5).timeout
	if not target: return
	print(self, " 攻击： ", target)
	var damage : float = attack_power - target.defense_power
	await target.hurt(damage)

## 受击
func hurt(damage: float) -> void:
	hurted.emit(damage)
	print(self, " 受到伤害： ", damage)
	current_health -= damage
	current_health = max(current_health, 0)
	if current_health <= 0:
		_die()

## 死亡
func _die() -> void:
	print("角色死亡：", self)
	died.emit()

## 获取随机敌人
func _get_random_enemy() -> CombatComponent:
	assert(_current_combat, "当前战斗不存在！不是战斗状态么？")
	return _current_combat.get_random_enemy(self)

func _to_string() -> String:
	return owner.to_string()
