extends Node2D
class_name Character

## 战斗角色

@export var max_health : float = 100
@export_storage var _current_health : float = 100
@export var attack_power : float = 10.0
@export var defense_power : float = 5
@export var speed : float = 1

# 角色的名称
@export var cha_name : String = ""
var is_alive : bool :
	get:
		return _current_health > 0

func _ready() -> void:
	_current_health = max_health

## 战斗开始
func combat_start() -> void:
	print(self, "战斗开始！")

## 回合开始
func turn_start() -> void:
	print(self, "====== 回合开始")
	var target := _get_target()
	hit(target)

## 回合结束
func turn_end() -> void:
	print(self, "====== 回合结束")

## 战斗结束
func combat_end() -> void:
	print(self, " 战斗结束", "剩余血量: ", _current_health)

## 攻击
func hit(target: Character) -> void:
	if not target: return
	print(self, " 攻击： ", target)
	var damage := attack_power - target.defense_power
	target.hurt(damage)

## 受击
func hurt(damage) -> void:
	print(self, " 受到伤害： ", damage)
	_current_health -= damage
	_current_health = max(_current_health, 0)
	if _current_health <= 0:
		_die()

## 死亡
func _die() -> void:
	print("角色死亡：", self)
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

func _to_string() -> String:
	#return "name : {cha_name} speed : {speed} health : {health} attack : {attack} defense : {defense}".format({
		#"cha_name": cha_name,
		#"speed": speed,
		#"health": _current_health,
		#"attack": attack_power,
		#"defense": defense_power,
	#})
	return cha_name
