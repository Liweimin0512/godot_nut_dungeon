extends Node
class_name UILocalizationComponent

## 本地化键
@export var key: String = ""
## 本地化参数
@export var params: Dictionary = {}
## 自动更新
@export var auto_update: bool = true

var _owner: Node

func _ready() -> void:
    _owner = get_parent()
    if not _owner:
        push_error("UILocalizationComponent must be child of a Node")
        return
        
    if UIManager.is_module_enabled("localization"):
        var localization_manager = UIManager.localization_manager
        if localization_manager:
            localization_manager.locale_changed.connect(_on_locale_changed)
            if auto_update:
                update_localization()

func update_localization() -> void:
    pass  # 由子类实现

func _on_locale_changed(_locale: String) -> void:
    if auto_update:
        update_localization()

## 设置本地化键
func set_localization_key(new_key: String, new_params: Dictionary = {}) -> void:
    key = new_key
    params = new_params
    update_localization()