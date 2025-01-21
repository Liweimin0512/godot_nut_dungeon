# source/localization/localizable.gd
extends Control
class_name Localizable

@export var translation_key: String
@export var font_key: String

func _ready() -> void:
    add_to_group("localizable")
    LocalizationManager.locale_changed.connect(_on_locale_changed)
    _update_localization()

func _update_localization() -> void:
    if translation_key:
        text = LocalizationManager.tr(translation_key)
    
    if font_key:
        var font = LocalizationManager.get_font(font_key)
        if font:
            add_theme_font_override("font", font)

func _on_locale_changed(_locale: String) -> void:
    _update_localization()