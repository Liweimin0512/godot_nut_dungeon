extends RefCounted
class_name Message

enum MESSAGE_TYPE{
	NONE,
	COMBAT_START,
	TURN_START,
	TURN_END,
	CHARACTER_ACTION
}
	
var message_type : MESSAGE_TYPE
var callable : Callable

func process() -> void:
	await callable.call()
