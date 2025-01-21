@tool
extends Control
class_name UIStateInspector

## UI状态检查器
## 用于查看和编辑UI节点的属性状态

var _property_tree: Tree
var _current_node: Control
var _update_timer: Timer
var _property_cache: Dictionary = {}

func _ready() -> void:
    setup_inspector()
    _setup_timer()

func _exit_tree() -> void:
    if _update_timer:
        _update_timer.queue_free()
    _update_timer = null
    _property_cache.clear()

func setup_inspector() -> void:
    # 创建属性树
    _property_tree = Tree.new()
    _property_tree.columns = 2
    _property_tree.set_column_title(0, "Property")
    _property_tree.set_column_title(1, "Value")
    _property_tree.set_column_titles_visible(true)
    _property_tree.set_column_expand(0, true)
    _property_tree.set_column_expand(1, true)
    _property_tree.set_column_custom_minimum_width(0, 150)
    _property_tree.set_column_custom_minimum_width(1, 150)
    add_child(_property_tree)
    
    # 设置大小
    custom_minimum_size = Vector2(300, 400)
    _property_tree.size = size

func _setup_timer() -> void:
    _update_timer = Timer.new()
    _update_timer.wait_time = 0.5  # 更新频率
    _update_timer.timeout.connect(_update_property_values)
    add_child(_update_timer)
    _update_timer.start()

## 检查节点
func inspect_node(node: Control) -> void:
    if not is_instance_valid(node):
        return
        
    _current_node = node
    _property_cache.clear()
    update_properties()

## 更新属性
func update_properties() -> void:
    if not is_instance_valid(_property_tree) or not is_instance_valid(_current_node):
        return
    
    _property_tree.clear()
    var root = _property_tree.create_item()
    root.set_text(0, _current_node.name)
    
    # 基本属性
    var basic = _property_tree.create_item(root)
    basic.set_text(0, "Basic Properties")
    _add_basic_properties(basic)
    
    # 主题属性
    var theme = _property_tree.create_item(root)
    theme.set_text(0, "Theme Properties")
    _add_theme_properties(theme)
    
    # 自定义属性
    var custom = _property_tree.create_item(root)
    custom.set_text(0, "Custom Properties")
    _add_custom_properties(custom)

## 添加基本属性
func _add_basic_properties(parent: TreeItem) -> void:
    var properties = {
        "Position": _current_node.position,
        "Size": _current_node.size,
        "Visible": _current_node.visible,
        "Modulate": _current_node.modulate,
        "Scale": _current_node.scale
    }
    
    for prop_name in properties:
        var item = _property_tree.create_item(parent)
        item.set_text(0, prop_name)
        _add_property_value(item, properties[prop_name])
        _property_cache[item] = {"name": prop_name.to_lower(), "type": "basic"}

## 添加主题属性
func _add_theme_properties(parent: TreeItem) -> void:
    var theme = _current_node.theme
    if not theme:
        return
    
    var properties = theme.get_property_list()
    for prop in properties:
        if prop.usage & PROPERTY_USAGE_EDITOR:
            var item = _property_tree.create_item(parent)
            item.set_text(0, prop.name)
            _add_property_value(item, theme.get(prop.name))
            _property_cache[item] = {"name": prop.name, "type": "theme"}

## 添加自定义属性
func _add_custom_properties(parent: TreeItem) -> void:
    var properties = _current_node.get_property_list()
    for prop in properties:
        if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
            var item = _property_tree.create_item(parent)
            item.set_text(0, prop.name)
            _add_property_value(item, _current_node.get(prop.name))
            _property_cache[item] = {"name": prop.name, "type": "custom"}

## 添加属性值
func _add_property_value(item: TreeItem, value: Variant) -> void:
    match typeof(value):
        TYPE_VECTOR2, TYPE_VECTOR2I:
            item.set_text(1, "(%d, %d)" % [value.x, value.y])
        TYPE_COLOR:
            item.set_text(1, "#%s" % value.to_html())
            item.set_custom_color(1, value)
        TYPE_OBJECT:
            item.set_text(1, str(value))
        _:
            item.set_text(1, str(value))

## 更新属性值
func _update_property_values() -> void:
    if not visible or not is_instance_valid(_current_node):
        return
        
    for item in _property_cache:
        if not is_instance_valid(item):
            continue
            
        var prop = _property_cache[item]
        var value = null
        
        match prop.type:
            "basic":
                value = _current_node.get(prop.name)
            "theme":
                if _current_node.theme:
                    value = _current_node.theme.get(prop.name)
            "custom":
                value = _current_node.get(prop.name)
        
        if value != null:
            _add_property_value(item, value)

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        if is_instance_valid(_property_tree):
            _property_tree.size = size

## 获取当前检查的节点
func get_inspected_node() -> Control:
    return _current_node if is_instance_valid(_current_node) else null

## 设置更新间隔
func set_update_interval(interval: float) -> void:
    if _update_timer:
        _update_timer.wait_time = interval