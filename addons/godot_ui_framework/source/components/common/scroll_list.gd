# source/components/common/scroll_list.gd
extends ScrollContainer
class_name ScrollList

signal item_selected(item_data: Variant, index: int)
signal item_clicked(item_data: Variant, index: int)
signal scroll_ended

@export_group("List Settings")
@export var item_scene: PackedScene
@export var vertical_spacing: float = 5.0
@export var horizontal_spacing: float = 5.0
@export var columns: int = 1
@export var auto_height: bool = true

@export_group("Performance")
@export var pool_size: int = 20
@export var buffer_items: int = 4

var _container: GridContainer
var _item_pool: Array[Control] = []
var _visible_items: Array[Control] = []
var _data: Array = []
var _item_height: float = 0.0
var _last_scroll_pos: float = 0.0
var _is_scrolling: bool = false

func _ready() -> void:
    setup_list()
    scroll_ended.connect(_on_scroll_ended)

func setup_list() -> void:
    _container = GridContainer.new()
    _container.columns = columns
    add_child(_container)
    
    # 创建对象池
    for i in pool_size:
        var item = item_scene.instantiate()
        item.hide()
        _item_pool.append(item)
        _container.add_child(item)
    
    # 设置间距
    _container.add_theme_constant_override("h_separation", horizontal_spacing)
    _container.add_theme_constant_override("v_separation", vertical_spacing)

func set_data(data: Array) -> void:
    _data = data
    refresh_list()

func refresh_list() -> void:
    # 隐藏所有项
    for item in _visible_items:
        item.hide()
    _visible_items.clear()
    
    # 计算可见区域
    var visible_start = int(scroll_vertical / _item_height)
    var visible_end = visible_start + (pool_size - buffer_items)
    
    # 显示可见项
    for i in range(visible_start, min(visible_end, _data.size())):
        var item = _get_pool_item()
        if item:
            _setup_item(item, _data[i], i)
            _visible_items.append(item)

func _get_pool_item() -> Control:
    for item in _item_pool:
        if not item.visible:
            return item
    return null

func _setup_item(item: Control, data: Variant, index: int) -> void:
    item.show()
    if item.has_method("set_data"):
        item.set_data(data)
    
    # 连接信号
    if not item.gui_input.is_connected(_on_item_gui_input.bind(data, index)):
        item.gui_input.connect(_on_item_gui_input.bind(data, index))

func _on_item_gui_input(event: InputEvent, data: Variant, index: int) -> void:
    if event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_LEFT:
            item_clicked.emit(data, index)

func _process(_delta: float) -> void:
    if _last_scroll_pos != scroll_vertical:
        _is_scrolling = true
        _last_scroll_pos = scroll_vertical
        refresh_list()
    elif _is_scrolling:
        _is_scrolling = false
        scroll_ended.emit()

func _on_scroll_ended() -> void:
    refresh_list()