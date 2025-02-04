@tool
extends Resource
class_name RecipeData

## 合成配方数据

@export var id: int
@export var name: String
@export var name_zh: String
@export var description: String
@export var description_zh: String
@export var result_item: int
@export var result_amount: int = 1
@export var materials: Array[int]
@export var material_amounts: Array[int]
@export var unlock_condition: String = "default"

## 获取当前语言的名称
func get_localized_name() -> String:
	return name_zh if TranslationServer.get_locale() == "zh" else name

## 获取当前语言的描述
func get_localized_description() -> String:
	return description_zh if TranslationServer.get_locale() == "zh" else description

## 检查是否有足够的材料
func check_materials(inventory: InventoryComponent) -> bool:
	for i in range(materials.size()):
		var material_id = materials[i]
		var required_amount = material_amounts[i]
		var found_amount = 0
		
		for item in inventory.get_all_items():
			if item.item_data.id == material_id:
				found_amount += item.quantity
				
		if found_amount < required_amount:
			return false
	
	return true

## 消耗材料
func consume_materials(inventory: InventoryComponent) -> bool:
	if not check_materials(inventory):
		return false
		
	for i in range(materials.size()):
		var material_id = materials[i]
		var required_amount = material_amounts[i]
		var remaining_amount = required_amount
		
		# 遍历所有槽位，寻找材料并消耗
		for slot in range(inventory.slots_count):
			var item = inventory.get_item(slot)
			if not item or item.item_data.id != material_id:
				continue
				
			var amount_to_remove = min(remaining_amount, item.quantity)
			inventory.remove_item(slot, amount_to_remove)
			remaining_amount -= amount_to_remove
			
			if remaining_amount <= 0:
				break
	
	return true
