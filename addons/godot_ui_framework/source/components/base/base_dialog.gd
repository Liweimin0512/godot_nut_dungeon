extends BaseWindow
class_name BaseDialog

@export_group("Dialog Settings")
@export var dialog_type: DialogType = DialogType.NORMAL
@export var auto_close: bool = true
@export var close_delay: float = 0.0

enum DialogType {
    NORMAL,     # 普通对话框
    MODAL,      # 模态对话框
    POPUP       # 弹出提示
}

signal confirmed
signal cancelled
signal custom_button_pressed(button_id: int)

func show_dialog() -> void:
    # 显示对话框
    pass

func close_dialog() -> void:
    # 关闭对话框
    pass