extends Message
class_name MessageTurnEnd

func _init(callable: Callable) -> void:
	message_type = MESSAGE_TYPE.TURN_END
	self.callable = callable
