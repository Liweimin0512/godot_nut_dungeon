# source/debug/ui_state_inspector.gd
extends Control
class_name UIStateInspector

var _property_tree: Tree
var _current_node: Control

func _ready() -> void:
    setup_inspector()

func setup_inspector() -> void:
    _property_tree = Tree.new()
    _property_tree.columns = 2
    _property_tree.set_column_title(0, "Property")
    _property_tree.set_column_title(1, "Value")
    add_child(_property_tree)

func inspect_node(node: Control) -> void:
    _current_node = node
    update_properties()

func update_properties() -> void:
    _property_tree.clear()
    if not _current_node:
        return
    
    var root = _property_tree.create_item()
    
    # 基本属性
    _add_property(root, "Name", _current_node.name)
    _add_property(root, "Position", _current_node.position)
    _add_property(root, "Size", _current_node.size)
    _add_property(root, "Visible", _current_node.visible)
    
    # 主题属性
    var theme_props = _current_node.get_theme().get_property_list()
    var theme_item = _property_tree.create_item(root)
    theme_item.set_text(0, "Theme Properties")
    for prop in theme_props:
        _add_property(theme_item, prop.name, _current_node.get_theme().get(prop.name))
    
    # 自定义属性
    var custom_item = _property_tree.create_item(root)
    custom_item.set_text(0, "Custom Properties")
    for property in _current_node.get_property_list():
        if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
            _add_property(custom_item, property.name, _current_node.get(property.name))

func _add_property(parent: TreeItem, name: String, value: Variant) -> void:
    var item = _property_tree.create_item(parent)
    item.set_text(0, name)
    item.set_text(1, str(value))