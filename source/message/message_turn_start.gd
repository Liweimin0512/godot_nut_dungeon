extends Message
class_name MessageTurnStart

var turn_count : int

func _init(turn_count: int, callable: Callable) -> void:
	message_type = MESSAGE_TYPE.TURN_START
	self.turn_count = turn_count
	self.callable = callable

func process() -> void:
	await callable.call(turn_count)
