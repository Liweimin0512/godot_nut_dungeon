extends BuffAbility
class_name TurnBasedBuffAbility

## 回合制BUFF

## 回合开始前, 更新BUFF
func on_pre_turn_start() -> void:
    update()

