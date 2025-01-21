@tool
extends Tree
class_name UIHierarchyViewer

## UI层级查看器
## 显示场景中的UI节点层级结构

var _root_item: TreeItem
var _node_items: Dictionary = {}
var _update_timer: Timer
var _icons: Dictionary = {}

## 节点选中信号
signal node_selected(node: Control)

func _ready() -> void:
    setup_tree()
    _setup_icons()
    _setup_timer()

func _exit_tree() -> void:
    if _update_timer:
        _update_timer.queue_free()
    _update_timer = null
    
    # 清理图标资源
    _icons.clear()

func setup_tree() -> void:
    columns = 3
    set_column_title(0, "Node")
    set_column_title(1, "Position")
    set_column_title(2, "Size")
    
    set_column_expand(0, true)
    set_column_expand(1, false)
    set_column_expand(2, false)
    set_column_custom_minimum_width(1, 100)
    set_column_custom_minimum_width(2, 100)
    
    item_selected.connect(_on_item_selected)

func _setup_icons() -> void:
    # 预加载常用图标
    _icons = {
        # "visible": preload("res://addons/godot_ui_framework/assets/icons/visible.svg"),
        # "hidden": preload("res://addons/godot_ui_framework/assets/icons/hidden.svg"),
        # "control": preload("res://addons/godot_ui_framework/assets/icons/control.svg")
    }

func _setup_timer() -> void:
    _update_timer = Timer.new()
    _update_timer.wait_time = 1.0
    _update_timer.timeout.connect(update_hierarchy)
    add_child(_update_timer)
    _update_timer.start()

## 更新UI层级
func update_hierarchy() -> void:
    if not visible:
        return
        
    clear()
    _node_items.clear()
    _root_item = create_item()
    _root_item.set_text(0, "UI Root")
    
    # 从UI管理器获取根节点
    if UIManager.has_method("get_ui_root"):
        var root = UIManager.get_ui_root()
        if root:
            _add_node_to_tree(root, _root_item)

## 添加节点到树中
func _add_node_to_tree(node: Node, parent_item: TreeItem) -> void:
    if not is_instance_valid(node):
        return
        
    if node is Control:
        var item = create_item(parent_item)
        item.set_text(0, node.name)
        item.set_text(1, str(Vector2i(node.position)))
        item.set_text(2, str(Vector2i(node.size)))
        _node_items[item] = node
        
        # 添加图标
        item.set_icon(0, _icons["control"])
        item.add_button(0, _icons["visible" if node.visible else "hidden"])
        
    # 递归添加子节点
    for child in node.get_children():
        _add_node_to_tree(child, parent_item if not (node is Control) else _node_items.find_key(node))

## 选中节点处理
func _on_item_selected() -> void:
    var selected_item = get_selected()
    if selected_item and _node_items.has(selected_item):
        var node = _node_items[selected_item]
        if is_instance_valid(node):
            node_selected.emit(node)

## 设置更新间隔
func set_update_interval(interval: float) -> void:
    if _update_timer:
        _update_timer.wait_time = interval

## 获取选中的节点
func get_selected_node() -> Control:
    var selected_item = get_selected()
    if selected_item and _node_items.has(selected_item):
        return _node_items[selected_item]
    return null