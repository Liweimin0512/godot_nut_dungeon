extends Node
class_name InventoryComponent

## 背包组件
## 负责管理物品栏和物品操作

# 信号
## 物品添加信号
signal item_added(item: ItemInstance, slot: int)
## 物品移除信号
signal item_removed(item: ItemInstance, slot: int)
## 物品使用信号
signal item_used(item: ItemInstance)
## 背包槽位数量变化信号
signal slots_changed()

# 导出变量
@export var slots_count: int = 20  ## 背包槽位数量

# 内部变量
## 槽位数组
var _slots: Array[ItemInstance] = []
## 日志
var _logger = CoreSystem.logger

func _ready() -> void:
	# 初始化槽位
	_slots.resize(slots_count)
	_logger.debug("Inventory initialized with %d slots" % slots_count)

## 添加物品
## [param item] 物品实例
## [return] 是否添加成功
func add_item(item: ItemInstance) -> bool:
	if not item:
		return false
		
	# 先尝试堆叠
	if item.item_data.is_stackable():
		for i in range(slots_count):
			var slot_item = _slots[i]
			if slot_item and slot_item.item_data.id == item.item_data.id:
				var remaining = slot_item.try_stack(item.quantity)
				if remaining < item.quantity:
					item_added.emit(item, i)
					if remaining == 0:
						return true
					item.quantity = remaining
	
	# 找空位放置
	for i in range(slots_count):
		if not _slots[i]:
			_slots[i] = item
			item_added.emit(item, i)
			return true
	
	_logger.warning("Inventory is full")
	return false

## 移除物品
## [param slot] 槽位索引
## [param amount] 移除数量
## [return] 移除的物品实例
func remove_item(slot: int, amount: int = 1) -> ItemInstance:
	if slot < 0 or slot >= slots_count:
		return null
		
	var item = _slots[slot]
	if not item:
		return null
		
	if item.quantity <= amount:
		_slots[slot] = null
		item_removed.emit(item, slot)
		slots_changed.emit()
		return item
	else:
		var split_item = item.split_stack(amount)
		item_removed.emit(split_item, slot)
		slots_changed.emit()
		return split_item

## 使用物品
## [param slot] 槽位索引
## [return] 是否使用成功
func use_item(slot: int) -> bool:
	var item = get_item(slot)
	if not item:
		return false
		
	if not item.item_data.is_consumable():
		_logger.warning("Item is not consumable")
		return false
		
	# 使用物品效果
	var ability_system = CoreSystem.ability_system
	if ability_system and item.item_data.ability_id:
		ability_system.activate_ability(item.item_data.ability_id, get_parent(), item.get_total_effects())
	
	# 减少数量
	remove_item(slot, 1)
	item_used.emit(item)
	return true

## 获取物品
## [param slot] 槽位索引
## [return] 物品实例
func get_item(slot: int) -> ItemInstance:
	if slot < 0 or slot >= slots_count:
		return null
	return _slots[slot]

## 交换物品位置
## [param from_slot] 从槽位索引
## [param to_slot] 到槽位索引
## [return] 是否交换成功
func swap_items(from_slot: int, to_slot: int) -> bool:
	if from_slot < 0 or from_slot >= slots_count or to_slot < 0 or to_slot >= slots_count:
		return false
		
	var temp = _slots[to_slot]
	_slots[to_slot] = _slots[from_slot]
	_slots[from_slot] = temp
	
	slots_changed.emit()
	return true

## 获取所有物品
## [return] 物品实例数组
func get_all_items() -> Array[ItemInstance]:
	var items: Array[ItemInstance] = []
	for item in _slots:
		if item:
			items.append(item)
	return items

## 清空背包
func clear() -> void:
	_slots.clear()
	_slots.resize(slots_count)
	slots_changed.emit()

## 获取空槽位数量
## [return] 空槽位数量
func get_empty_slots_count() -> int:
	var count = 0
	for item in _slots:
		if not item:
			count += 1
	return count

## 是否有足够空间
## [param item] 物品实例
## [return] 是否有足够空间
func has_space_for(item: ItemInstance) -> bool:
	if not item:
		return false
		
	var required_space = 1
	if item.item_data.is_stackable():
		var remaining = item.quantity
		for slot_item in _slots:
			if slot_item and slot_item.item_data.id == item.item_data.id:
				remaining -= (slot_item.item_data.stack_size - slot_item.quantity)
		required_space = ceili(float(remaining) / item.item_data.stack_size)
	
	return get_empty_slots_count() >= required_space
