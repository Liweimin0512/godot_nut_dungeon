# source/module/localization/components/ui_localized_texture_component.gd
extends UILocalizationComponent
class_name UILocalizedTextureComponent

## 目标贴图属性
@export var texture_property: String = "texture"

func update_localization() -> void:
    if not key or not _owner or not UIManager.is_module_enabled("localization"):
        return
        
    var localization_manager = UIManager.localization_manager
    if not localization_manager:
        return
    
    var texture = localization_manager.get_localized_resource(key) as Texture2D
    if texture and _owner.has_method("set_" + texture_property):
        _owner.set(texture_property, texture)