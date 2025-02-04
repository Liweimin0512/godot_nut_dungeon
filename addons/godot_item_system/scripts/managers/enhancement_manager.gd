extends Node

## 强化系统管理器
## 负责管理物品强化

# 信号
signal enhancement_succeeded(item: ItemInstance, level: int)
signal enhancement_failed(item: ItemInstance, level: int)

# 常量
const MAX_ENHANCEMENT_LEVEL = 10

# 内部变量
var _enhancement_data: Dictionary = {}
var _logger = CoreSystem.logger

func _ready() -> void:
	_load_enhancement_data()

## 加载强化数据
func _load_enhancement_data() -> void:
	var csv_path = "res://datatables/enhancements.csv"
	var table = GDDataForge.load_csv(csv_path)
	
	for row in table:
		var level = int(row["level"])
		_enhancement_data[level] = {
			"success_rate": float(row["success_rate"]),
			"cost_multiplier": float(row["cost_multiplier"]),
			"effect_multiplier": float(row["effect_multiplier"]),
			"material_amount": int(row["material_amount"])
		}
		
		_logger.debug("Loaded enhancement data for level %d" % level)

## 尝试强化
func try_enhance(item: ItemInstance, inventory: InventoryComponent) -> bool:
	if not item or not can_enhance(item):
		return false
	
	var next_level = item.enhancement_level + 1
	var data = _enhancement_data[next_level]
	
	# 检查材料和金钱
	var cost = calculate_enhancement_cost(item)
	if inventory.money < cost:
		_logger.warning("Not enough money for enhancement")
		return false
	
	var material_amount = data["material_amount"]
	if not _has_enough_materials(inventory, material_amount):
		_logger.warning("Not enough materials for enhancement")
		return false
	
	# 扣除材料和金钱
	inventory.remove_money(cost)
	_consume_materials(inventory, material_amount)
	
	# 判定是否成功
	var success = randf() * 100 < data["success_rate"]
	if success:
		item.enhancement_level = next_level
		enhancement_succeeded.emit(item, next_level)
	else:
		enhancement_failed.emit(item, next_level)
	
	return success

## 检查是否可以强化
func can_enhance(item: ItemInstance) -> bool:
	if not item:
		return false
		
	# 只有装备可以强化
	if item.item_data.type != ItemData.ItemType.EQUIPMENT:
		return false
		
	# 检查是否达到最大等级
	return item.enhancement_level < MAX_ENHANCEMENT_LEVEL

## 计算强化费用
func calculate_enhancement_cost(item: ItemInstance) -> int:
	var next_level = item.enhancement_level + 1
	if not _enhancement_data.has(next_level):
		return 0
		
	var base_cost = item.item_data.price
	return ceili(base_cost * _enhancement_data[next_level]["cost_multiplier"])

## 计算强化效果倍率
func calculate_effect_multiplier(level: int) -> float:
	if not _enhancement_data.has(level):
		return 1.0
	return _enhancement_data[level]["effect_multiplier"]

## 获取成功率
func get_success_rate(level: int) -> float:
	if not _enhancement_data.has(level):
		return 0.0
	return _enhancement_data[level]["success_rate"]

## 获取所需材料数量
func get_required_materials(level: int) -> int:
	if not _enhancement_data.has(level):
		return 0
	return _enhancement_data[level]["material_amount"]

## 检查是否有足够的材料
func _has_enough_materials(inventory: InventoryComponent, amount: int) -> bool:
	var total = 0
	for item in inventory.get_all_items():
		if item.item_data.type == ItemData.ItemType.MATERIAL:
			total += item.quantity
	return total >= amount

## 消耗材料
func _consume_materials(inventory: InventoryComponent, amount: int) -> void:
	var remaining = amount
	
	for slot in range(inventory.slots_count):
		var item = inventory.get_item(slot)
		if not item or item.item_data.type != ItemData.ItemType.MATERIAL:
			continue
			
		var consume = min(remaining, item.quantity)
		inventory.remove_item(slot, consume)
		remaining -= consume
		
		if remaining <= 0:
			break
