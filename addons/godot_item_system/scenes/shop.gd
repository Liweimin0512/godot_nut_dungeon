extends SceneComponent
class_name ShopUI

## 商店UI组件
## 显示和管理商店界面

# 导出变量
@export var inventory: InventoryComponent
@export var shop_items_container: GridContainer
@export var inventory_items_container: GridContainer
@export var shop_name_label: Label
@export var money_label: Label
@export var item_tip_scene: PackedScene

# 内部变量
var _item_tip: ItemTipUI
var _selected_shop_slot: ItemSlotUI
var _selected_inventory_slot: ItemSlotUI
var _logger = CoreSystem.logger

func _ready() -> void:
	super._ready()
	
	if not inventory:
		_logger.error("ShopUI: No inventory component assigned")
		return
	
	# 创建物品提示UI
	_item_tip = item_tip_scene.instantiate()
	add_child(_item_tip)
	_item_tip.hide()
	
	# 连接信号
	CoreSystem.shop_manager.shop_opened.connect(_on_shop_opened)
	CoreSystem.shop_manager.shop_closed.connect(_on_shop_closed)
	inventory.money_changed.connect(_update_money_display)
	
	# 初始化显示
	_update_money_display(inventory.money)

## 商店打开时
func _on_shop_opened(shop_data: ShopData) -> void:
	shop_name_label.text = shop_data.get_localized_name()
	_update_shop_items()
	_update_inventory_items()
	show()

## 商店关闭时
func _on_shop_closed(_shop_data: ShopData) -> void:
	hide()
	_item_tip.hide()

## 更新商店物品显示
func _update_shop_items() -> void:
	# 清除现有物品槽
	for child in shop_items_container.get_children():
		child.queue_free()
	
	# 创建新的物品槽
	var items = CoreSystem.shop_manager.get_shop_items()
	for i in range(items.size()):
		var slot = ItemSlotUI.new()
		slot.slot_index = i
		slot.item_instance = items[i]
		shop_items_container.add_child(slot)
		
		# 连接信号
		slot.item_clicked.connect(_on_shop_slot_clicked.bind(slot))
		slot.item_double_clicked.connect(_on_shop_slot_double_clicked.bind(slot))

## 更新背包物品显示
func _update_inventory_items() -> void:
	# 清除现有物品槽
	for child in inventory_items_container.get_children():
		child.queue_free()
	
	# 创建新的物品槽
	var items = inventory.get_all_items()
	for i in range(items.size()):
		var slot = ItemSlotUI.new()
		slot.slot_index = i
		slot.item_instance = items[i]
		inventory_items_container.add_child(slot)
		
		# 连接信号
		slot.item_clicked.connect(_on_inventory_slot_clicked.bind(slot))
		slot.item_double_clicked.connect(_on_inventory_slot_double_clicked.bind(slot))

## 更新金钱显示
func _update_money_display(amount: int) -> void:
	money_label.text = str(amount) + " 金币"

## 处理商店槽位点击
func _on_shop_slot_clicked(button: int, slot: ItemSlotUI) -> void:
	if button == MOUSE_BUTTON_LEFT:
		_selected_shop_slot = slot
		_selected_inventory_slot = null
		
		# 显示物品提示
		if slot.item_instance:
			_item_tip.item_instance = slot.item_instance
			_item_tip.set_tip_position(get_global_mouse_position())
			_item_tip.show()

## 处理商店槽位双击
func _on_shop_slot_double_clicked(slot: ItemSlotUI) -> void:
	if slot.item_instance:
		_buy_item(slot.item_instance)

## 处理背包槽位点击
func _on_inventory_slot_clicked(button: int, slot: ItemSlotUI) -> void:
	if button == MOUSE_BUTTON_LEFT:
		_selected_inventory_slot = slot
		_selected_shop_slot = null
		
		# 显示物品提示
		if slot.item_instance:
			_item_tip.item_instance = slot.item_instance
			_item_tip.set_tip_position(get_global_mouse_position())
			_item_tip.show()

## 处理背包槽位双击
func _on_inventory_slot_double_clicked(slot: ItemSlotUI) -> void:
	if slot.item_instance:
		_sell_item(slot.item_instance)

## 购买物品
func _buy_item(item: ItemInstance) -> void:
	var shop = CoreSystem.shop_manager.get_current_shop()
	if not shop:
		return
		
	var price = shop.calculate_buy_price(item)
	if inventory.money < price:
		_logger.warning("Not enough money")
		return
		
	if CoreSystem.shop_manager.buy_item(item.item_data.id, inventory):
		_update_inventory_items()
		_update_money_display(inventory.money)

## 出售物品
func _sell_item(item: ItemInstance) -> void:
	var shop = CoreSystem.shop_manager.get_current_shop()
	if not shop:
		return
		
	if CoreSystem.shop_manager.sell_item(item, inventory):
		_update_inventory_items()
		_update_money_display(inventory.money)

## 处理输入
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if _item_tip.visible:
			_item_tip.set_tip_position(get_global_mouse_position())
	elif event is InputEventMouseButton:
		if not event.pressed and _item_tip.visible:
			_item_tip.hide()
