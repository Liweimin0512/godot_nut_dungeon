extends Node
class_name CombatComponent

@export var max_health : float = 100
@export_storage var current_health : float = 100:
	set(value):
		current_health = value
		current_health_changed.emit(current_health)
@export var attack_power : float = 10.0
@export var defense_power : float = 5
@export var speed : float = 1
var is_alive : bool :
	get:
		return current_health > 0

signal hited(target: Character)
signal hurted(damage: int)
signal current_health_changed(value: float)
signal died

func _ready() -> void:
	current_health = max_health

## 战斗开始
func combat_start() -> void:
	print(self, "战斗开始！")

## 回合开始
func turn_start() -> void:
	print(self, "====== 回合开始")
	var target := _get_target()
	await get_tree().create_timer(0.5).timeout
	if not target: return
	await hit(target)

## 回合结束
func turn_end() -> void:
	print(self, "====== 回合结束")

## 战斗结束
func combat_end() -> void:
	print(self, " 战斗结束", "剩余血量: ", current_health)

## 攻击
func hit(target: CombatComponent) -> void:
	if not target: return
	hited.emit(target)
	await get_tree().create_timer(0.5).timeout
	if not target: return
	print(self, " 攻击： ", target)
	var damage : int = attack_power - target.defense_power
	await target.hurt(damage)

## 受击
func hurt(damage: int) -> void:
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

## 获取目标
func _get_target() -> CombatComponent:
	if not is_instance_valid(self): return null
	var tree := get_tree()
	if not is_instance_valid(tree): return null
	var target : CombatComponent
	if owner.is_in_group("Player"):
		var enemies := tree.get_nodes_in_group("Enemy")
		if enemies.is_empty(): return null
		target = enemies.pick_random().combat_component
	else:
		var players := tree.get_nodes_in_group("Player")
		if players.is_empty(): return null
		target = players.pick_random().combat_component
	return target
