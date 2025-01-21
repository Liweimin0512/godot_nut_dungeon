extends UIWidgetComponent
class_name ItemCardWidget

## 物品卡片控件

@export var _icon: TextureRect = $Icon
@export var _name_label: Label = $Name
@export var _desc_label: Label = $Description
@export var _count_label: Label = $Count

func _setup() -> void:
    # 初始化控件
    _refresh()

func _refresh() -> void:
    # 更新显示
    if _icon:
        _icon.texture = _model.get("icon")
    if _name_label:
        _name_label.text = _model.get("name", "")
    if _desc_label:
        _desc_label.text = _model.get("description", "")
    if _count_label:
        _count_label.text = str(_model.get("count", 0))
