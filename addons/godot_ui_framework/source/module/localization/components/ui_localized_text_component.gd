# source/module/localization/components/ui_localized_text_component.gd
extends UILocalizationComponent
class_name UILocalizedTextComponent

## 目标文本属性
@export var text_property: String = "text"

func update_localization() -> void:
    if not key or not _owner or not UIManager.is_module_enabled("localization"):
        return
        
    var localization_manager = UIManager.localization_manager
    if not localization_manager:
        return
    
    var translated_text = localization_manager.get_translation_str(key, params)
    if _owner.has_method("set_" + text_property):
        _owner.set(text_property, translated_text)