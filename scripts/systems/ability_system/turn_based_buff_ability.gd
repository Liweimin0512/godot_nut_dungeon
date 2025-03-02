extends Ability
class_name TurnBasedBuffAbility

## 回合制BUFF


func _init(_data: Dictionary = {}) -> void:
	add_tag("buff")


## 回合开始前, 更新BUFF
func on_pre_turn_start(_data: Dictionary = {}) -> void:
	#cast(data)
	pass


## 战斗结束时，销毁自身
func on_combat_end(_ability_context: Dictionary) -> void:
	remove()
