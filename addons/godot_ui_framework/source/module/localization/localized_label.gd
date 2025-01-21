# source/localization/localized_label.gd
extends Label
class_name LocalizedLabel

@export var translation_key: String
@export var translation_params: Dictionary

func _ready() -> void:
    add_to_group("localizable")
    LocalizationManager.locale_changed.connect(_on_locale_changed)
    _update_text()

func _update_text() -> void:
    text = LocalizationManager.tr(translation_key, translation_params)

func _on_locale_changed(_locale: String) -> void:
    _update_text()