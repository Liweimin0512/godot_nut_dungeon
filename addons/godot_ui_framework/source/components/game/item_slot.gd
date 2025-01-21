# source/components/item_slot.gd
extends Control
class_name ItemSlot

@export_group("Slot Settings")
@export var accept_types: Array[String] = []
@export var show_amount: bool = true
@export var show_name: bool = true
@export var show_rarity: bool = true

signal item_clicked(item_data: Dictionary)
signal item_dropped(item_data: Dictionary)
signal item_picked(item_data: Dictionary)

func set_item(item_data: Dictionary) -> void:
    # 设置物品数据
    pass