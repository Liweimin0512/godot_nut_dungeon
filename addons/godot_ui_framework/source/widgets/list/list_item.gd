# source/components/common/list_item.gd
extends Control
class_name ListItem

signal selected
signal deselected

@export var selectable: bool = true
@export var selected: bool = false:
    set(value):
        if selected != value:
            selected = value
            _update_selected_state()
            if selected:
                selected.emit()
            else:
                deselected.emit()

var item_data: Variant

func set_data(data: Variant) -> void:
    item_data = data
    _update_display()

func _update_display() -> void:
    # 子类实现具体显示逻辑
    pass

func _update_selected_state() -> void:
    # 子类实现选中状态显示逻辑
    pass

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_LEFT and selectable:
            selected = !selected