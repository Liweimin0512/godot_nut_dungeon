@tool
extends Resource
class_name ItemData

## 道具类型枚举
enum ItemType {
	CONSUMABLE,  # 消耗品
	EQUIPMENT,   # 装备
	MATERIAL,    # 材料
	QUEST       # 任务物品
}

## 道具稀有度枚举
enum ItemRarity {
	COMMON,     # 普通
	UNCOMMON,   # 优秀
	RARE,       # 稀有
	EPIC,       # 史诗
	LEGENDARY   # 传说
}

## 基础属性
@export var id: int
@export var name: String
@export var name_zh: String
@export var description: String
@export var description_zh: String
@export var icon: Texture2D
@export var type: ItemType
@export var rarity: ItemRarity
@export var stack_size: int = 1
@export var price: int = 0

## 游戏性相关
@export var ability_id: String  # 关联的技能ID
@export var effects: Dictionary # 物品效果

## 获取当前语言的名称
func get_localized_name() -> String:
	return name_zh if TranslationServer.get_locale() == "zh" else name

## 获取当前语言的描述
func get_localized_description() -> String:
	return description_zh if TranslationServer.get_locale() == "zh" else description

## 获取稀有度颜色
func get_rarity_color() -> Color:
	match rarity:
		ItemRarity.COMMON:
			return Color.WHITE
		ItemRarity.UNCOMMON:
			return Color.GREEN
		ItemRarity.RARE:
			return Color.BLUE
		ItemRarity.EPIC:
			return Color.PURPLE
		ItemRarity.LEGENDARY:
			return Color.YELLOW
	return Color.WHITE

## 是否可堆叠
func is_stackable() -> bool:
	return stack_size > 1

## 是否是装备
func is_equipment() -> bool:
	return type == ItemType.EQUIPMENT

## 是否是消耗品
func is_consumable() -> bool:
	return type == ItemType.CONSUMABLE

## 是否是材料
func is_material() -> bool:
	return type == ItemType.MATERIAL

## 是否是任务物品
func is_quest_item() -> bool:
	return type == ItemType.QUEST
