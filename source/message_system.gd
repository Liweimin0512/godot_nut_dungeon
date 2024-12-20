extends Node

## 消息队列管理器

var messages := []

func push_message(message: Message):
	messages.append(message)

func process_messages() -> void:
	while not messages.is_empty():
		var message = messages.pop_front()
		await message.process()
