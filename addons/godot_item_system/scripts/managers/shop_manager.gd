extends Node

## 商店管理器
## 负责管理商店数据和交易操作

# 信号
signal shop_opened(shop_data: ShopData)
signal shop_closed(shop_data: ShopData)
signal item_bought(item: ItemInstance, price: int)
signal item_sold(item: ItemInstance, price: int)

# 内部变量
var _shop_data_table: Dictionary = {}
var _current_shop: ShopData
var _logger = CoreSystem.logger

func _ready() -> void:
	_load_shop_data()

## 加载商店数据
func _load_shop_data() -> void:
	var csv_path = "res://datatables/shops.csv"
	var table = GDDataForge.load_csv(csv_path)
	
	for row in table:
		var shop_data = ShopData.new()
		shop_data.id = int(row["id"])
		shop_data.name = row["name"]
		shop_data.name_zh = row["name_zh"]
		shop_data.description = row["description"]
		shop_data.description_zh = row["description_zh"]
		shop_data.items = row["items"].split(",").map(func(x): return int(x))
		shop_data.buy_rate = float(row["buy_rate"])
		shop_data.sell_rate = float(row["sell_rate"])
		
		_shop_data_table[shop_data.id] = shop_data
		_logger.debug("Loaded shop data: %s" % shop_data.name)

## 打开商店
func open_shop(shop_id: int) -> void:
	if not _shop_data_table.has(shop_id):
		_logger.error("Failed to open shop: invalid shop id %d" % shop_id)
		return
		
	_current_shop = _shop_data_table[shop_id]
	shop_opened.emit(_current_shop)

## 关闭商店
func close_shop() -> void:
	if _current_shop:
		var shop = _current_shop
		_current_shop = null
		shop_closed.emit(shop)

## 购买物品
func buy_item(item_id: int, inventory: InventoryComponent) -> bool:
	if not _current_shop:
		_logger.error("No shop is currently open")
		return false
		
	if not _current_shop.items.has(item_id):
		_logger.error("Shop doesn't sell this item")
		return false
		
	var item = CoreSystem.item_manager.create_item(item_id)
	if not item:
		return false
		
	var price = _current_shop.calculate_buy_price(item)
	if not inventory.remove_money(price):
		_logger.warning("Not enough money")
		return false
		
	if not inventory.add_item(item):
		inventory.add_money(price)  # 退还金钱
		return false
		
	item_bought.emit(item, price)
	return true

## 出售物品
func sell_item(item: ItemInstance, inventory: InventoryComponent) -> bool:
	if not _current_shop:
		_logger.error("No shop is currently open")
		return false
		
	var price = _current_shop.calculate_sell_price(item)
	inventory.add_money(price)
	item_sold.emit(item, price)
	return true

## 获取商店数据
func get_shop_data(shop_id: int) -> ShopData:
	return _shop_data_table.get(shop_id)

## 获取当前商店
func get_current_shop() -> ShopData:
	return _current_shop

## 获取商店商品列表
func get_shop_items() -> Array[ItemInstance]:
	if not _current_shop:
		return []
		
	var items: Array[ItemInstance] = []
	for item_id in _current_shop.items:
		var item = CoreSystem.item_manager.create_item(item_id)
		if item:
			items.append(item)
	return items
