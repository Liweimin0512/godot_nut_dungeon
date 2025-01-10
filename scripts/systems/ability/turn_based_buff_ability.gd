extends BuffAbility
class_name TurnBasedBuffAbility

## 回合制BUFF


## 回合开始前, 更新BUFF
func on_pre_turn_start(_data: Dictionary = {}) -> void:
	_update()

## 战斗结束时，销毁自身
func on_combat_end(_ability_context: Dictionary) -> void:
	remove()
