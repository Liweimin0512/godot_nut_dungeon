# source/module/localization/components/ui_localized_audio_component.gd
extends UILocalizationComponent
class_name UILocalizedAudioComponent

## 目标音频属性
@export var audio_property: String = "stream"

func update_localization() -> void:
    if not key or not _owner or not UIManager.is_module_enabled("localization"):
        return
        
    var localization_manager = UIManager.localization_manager
    if not localization_manager:
        return
    
    var audio = localization_manager.get_localized_resource(key) as AudioStream
    if audio and _owner.has_method("set_" + audio_property):
        _owner.set(audio_property, audio)