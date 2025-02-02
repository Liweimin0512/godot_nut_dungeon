@tool
extends Resource
class_name ShopData

## 商店数据

@export var id: int
@export var name: String
@export var name_zh: String
@export var description: String
@export var description_zh: String
@export var items: Array[int]
@export var buy_rate: float = 1.0  # 购买价格倍率
@export var sell_rate: float = 0.5 # 出售价格倍率

## 获取当前语言的名称
func get_localized_name() -> String:
	return name_zh if TranslationServer.get_locale() == "zh" else name

## 获取当前语言的描述
func get_localized_description() -> String:
	return description_zh if TranslationServer.get_locale() == "zh" else description

## 计算购买价格
func calculate_buy_price(item: ItemInstance) -> int:
	return ceili(item.get_value() * buy_rate)

## 计算出售价格
func calculate_sell_price(item: ItemInstance) -> int:
	return ceili(item.get_value() * sell_rate)
