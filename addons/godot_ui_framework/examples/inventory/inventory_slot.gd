extends Control

## 物品槽组件
class_name InventorySlot

@onready var item_icon: TextureRect = $ItemIcon
@onready var item_count: Label = $ItemCount
@onready var background: Panel = $Background

signal item_clicked(slot_index: int)

var slot_index: int = 0
var item_data: Dictionary = {}

func _ready() -> void:
	background.gui_input.connect(_on_background_gui_input)
	refresh_empty()

func refresh_empty() -> void:
	item_icon.texture = null
	item_count.text = ""
	item_data = {}

func refresh_item(data: Dictionary) -> void:
	item_data = data
	if data.has("icon"):
		item_icon.texture = data.icon
	if data.has("count"):
		item_count.text = str(data.count) if data.count > 1 else ""

func _on_background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			item_clicked.emit(slot_index)
