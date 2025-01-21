extends Node
class_name UIThemeComponent

## 是否影响子节点
@export var affect_children: bool = true
## 主题名称，为空则使用当前主题
@export var theme_name: String = ""
## 是否自动应用主题
@export var auto_apply: bool = true
## 自定义样式覆盖
@export var style_overrides: Dictionary = {}

## 主题变更信号
signal theme_applied(theme: Theme)

var _current_theme: String = ""
var _owner_control: Control

func _ready() -> void:
    # 获取所属的Control节点
    _owner_control = get_parent() as Control
    if not _owner_control:
        push_error("UIThemeComponent must be child of a Control node")
        return
    
    # 连接主题管理器信号
    if UIManager.is_module_enabled("theme"):
        var theme_manager = UIManager.theme_manager
        if theme_manager:
            theme_manager.theme_changed.connect(_on_global_theme_changed)
            theme_manager.style_changed.connect(_on_global_style_changed)
    
    # 如果设置了自动应用，立即应用主题
    if auto_apply:
        apply_theme()

## 应用主题
func apply_theme() -> void:
    if not _owner_control:
        return
        
    var theme_manager = UIManager.theme_manager
    if not theme_manager:
        return
    
    # 使用指定主题或当前主题
    var target_theme = theme_name if not theme_name.is_empty() else theme_manager.current_theme
    if target_theme.is_empty():
        return
    
    # 获取主题实例
    var theme_instance = theme_manager._theme_cache.get(target_theme)
    if not theme_instance:
        return
    
    # 应用主题
    _current_theme = target_theme
    _apply_theme_to_node(_owner_control, theme_instance)
    
    # 发送信号
    theme_applied.emit(theme_instance)

## 递归应用主题到节点
func _apply_theme_to_node(node: Control, theme: Theme) -> void:
    # 应用主题到当前节点
    node.theme = theme
    
    # 应用样式覆盖
    _apply_style_overrides(node)
    
    # 如果启用了子节点影响，递归应用到子节点
    if affect_children:
        for child in node.get_children():
            if child is Control and not child.has_node("UIThemeComponent"):
                _apply_theme_to_node(child, theme)

## 应用样式覆盖
func _apply_style_overrides(node: Control) -> void:
    for style_name in style_overrides:
        var value = style_overrides[style_name]
        match typeof(value):
            TYPE_COLOR:
                node.add_theme_color_override(style_name, value)
            TYPE_INT:
                node.add_theme_constant_override(style_name, value)
            TYPE_OBJECT:
                if value is Font:
                    node.add_theme_font_override(style_name, value)
                elif value is StyleBox:
                    node.add_theme_stylebox_override(style_name, value)

## 全局主题变更回调
func _on_global_theme_changed(new_theme: String) -> void:
    # 如果没有指定主题名称，跟随全局主题变化
    if theme_name.is_empty():
        apply_theme()

## 全局样式变更回调
func _on_global_style_changed(style_name: String, value: Variant) -> void:
    # 如果样式覆盖中没有这个样式，应用全局样式变更
    if not style_overrides.has(style_name):
        apply_theme()

## 设置样式覆盖
func set_style_override(style_name: String, value: Variant) -> void:
    style_overrides[style_name] = value
    if _owner_control:
        _apply_style_overrides(_owner_control)

## 移除样式覆盖
func remove_style_override(style_name: String) -> void:
    style_overrides.erase(style_name)
    if _owner_control:
        _apply_style_overrides(_owner_control)

## 清除所有样式覆盖
func clear_style_overrides() -> void:
    style_overrides.clear()
    if _owner_control:
        _apply_style_overrides(_owner_control)