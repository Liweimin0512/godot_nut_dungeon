extends Tree
class_name UIHierarchyViewer

var _root_item: TreeItem
var _node_items: Dictionary = {}

## 节点选中
signal node_selected(node: Control)

func _ready() -> void:
    setup_tree()
    # 定时更新层级
    create_timer(1.0).timeout.connect(update_hierarchy)

func setup_tree() -> void:
    columns = 3
    set_column_title(0, "Node")
    set_column_title(1, "Position")
    set_column_title(2, "Size")
    
    item_selected.connect(_on_item_selected)

func update_hierarchy() -> void:
    clear()
    _node_items.clear()
    _root_item = create_item()
    _root_item.set_text(0, "UI Root")
    
    # 从场景树根节点开始遍历
    var root = get_tree().root
    _add_node_to_tree(root, _root_item)

func _add_node_to_tree(node: Node, parent_item: TreeItem) -> void:
    if node is Control:
        var item = create_item(parent_item)
        item.set_text(0, node.name)
        item.set_text(1, str(node.position))
        item.set_text(2, str(node.size))
        _node_items[item] = node
        
        # 添加可视化指示器
        if node.visible:
            item.set_icon(0, preload("res://icon_visible.png"))
        
    for child in node.get_children():
        _add_node_to_tree(child, parent_item)

func _on_item_selected() -> void:
    var selected_item = get_selected()
    if selected_item and _node_items.has(selected_item):
        var node = _node_items[selected_item]
        node_selected.emit(node)