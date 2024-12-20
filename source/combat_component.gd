extends Node
class_name CombatComponent

@export var max_health : float = 100
@export_storage var current_health : float = 100:
	set(value):
		current_health = value
		#progress_bar.value = current_health
		#label_health.text = "{0}/{1}".format([current_health,max_health ])
		current_health_changed.emit()
@export var attack_power : float = 10.0
@export var defense_power : float = 5
@export var speed : float = 1

signal hited(target: Character)
signal hurted(damage: int)
signal current_health_changed(value: float)

## 战斗开始
func combat_start() -> void:
	print(self, "战斗开始！")

## 回合开始
func turn_start() -> void:
	print(self, "====== 回合开始")
	var target := _get_target()
	await get_tree().create_timer(0.5).timeout
	await hit(target)

## 回合结束
func turn_end() -> void:
	print(self, "====== 回合结束")

## 战斗结束
func combat_end() -> void:
	print(self, " 战斗结束", "剩余血量: ", _current_health)

## 攻击
func hit(target: Character) -> void:
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
	_current_health -= damage
	_current_health = max(_current_health, 0)
	if _current_health <= 0:
		_die()

## 死亡
func _die() -> void:
	print("角色死亡：", self)
	animation_player.play("die")
	if not is_inside_tree(): return
	await get_tree().create_timer(1).timeout
	get_parent().remove_child(self)
	queue_free()

## 获取目标
func _get_target() -> Character:
	if not is_instance_valid(self): return null
	var tree := get_tree()
	if not is_instance_valid(tree): return null
	var target : Character
	if is_in_group("Player"):
		var enemies := tree.get_nodes_in_group("Enemy")
		target = enemies.pick_random()
	else:
		
		var players := tree.get_nodes_in_group("Player")
		target = players.pick_random()
	return target
