@tool
extends Resource
class_name ItemInstance

## 道具数据
@export var item_data: ItemData
## 数量
@export var quantity: int = 1
## 强化等级
@export var enhancement_level: int = 0
## 额外属性
@export var additional_effects: Dictionary = {}

## 信号
signal quantity_changed(new_quantity: int)
signal enhancement_level_changed(new_level: int)

## 内部变量
var _ability: Ability

## 获取总效果（基础效果 + 强化效果 + 额外效果）
func get_total_effects() -> Dictionary:
	var total = item_data.effects.duplicate()
	
	# 添加强化效果
	if enhancement_level > 0:
		var multiplier = CoreSystem.enhancement_manager.calculate_effect_multiplier(enhancement_level)
		for key in total:
			total[key] = ceil(total[key] * multiplier)
	
	# 添加额外效果
	for key in additional_effects:
		if key in total:
			total[key] += additional_effects[key]
		else:
			total[key] = additional_effects[key]
	
	return total

## 是否可以堆叠更多
func can_stack_more() -> bool:
	return item_data.is_stackable() and quantity < item_data.stack_size

## 尝试堆叠
## 返回无法堆叠的剩余数量
func try_stack(amount: int) -> int:
	if not can_stack_more():
		return amount
		
	var space_left = item_data.stack_size - quantity
	var amount_to_stack = min(amount, space_left)
	
	quantity += amount_to_stack
	quantity_changed.emit(quantity)
	return amount - amount_to_stack

## 分割堆叠
func split_stack(amount: int) -> ItemInstance:
	if amount >= quantity:
		return null
		
	var new_instance = duplicate()
	new_instance.quantity = amount
	quantity -= amount
	quantity_changed.emit(quantity)
	return new_instance

## 获取道具价值
func get_value() -> int:
	var base_value = item_data.price * quantity
	
	# 装备类型考虑强化等级
	if item_data.is_equipment():
		base_value *= (1 + enhancement_level * 0.2)
		
	# 考虑额外属性
	if not additional_effects.is_empty():
		base_value *= 1.1
		
	return base_value

## 使用物品
func use(target: Node) -> bool:
	if not item_data or not item_data.is_consumable():
		return false
		
	# 获取或创建技能
	if not _ability and item_data.ability_id:
		_ability = CoreSystem.item_ability_manager.create_ability(item_data.ability_id, self)
		if not _ability:
			return false
	
	# 激活技能
	if _ability:
		_ability.activate({"target": target})
		return true
	
	return false

## 获取技能
func get_ability() -> Ability:
	return _ability
