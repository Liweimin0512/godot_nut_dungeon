extends Message
class_name MessageCombatStart

func _init(callable: Callable) -> void:
	self.callable = callable
	message_type = MESSAGE_TYPE.COMBAT_START