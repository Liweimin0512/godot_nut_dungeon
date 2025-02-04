extends WidgetComponent
class_name ItemTipUI

## 物品提示UI组件
## 显示物品的详细信息

# 导出变量
@export var item_instance: ItemInstance:
	set(value):
		item_instance = value
		_update_display()

# 节点引用
@onready var name_label = $NameLabel
@onready var type_label = $TypeLabel
@onready var description_label = $DescriptionLabel
@onready var effects_container = $EffectsContainer
@onready var price_label = $PriceLabel

# 常量
const TYPE_NAMES = {
	ItemData.ItemType.CONSUMABLE: "消耗品",
	ItemData.ItemType.EQUIPMENT: "装备",
	ItemData.ItemType.MATERIAL: "材料",
	ItemData.ItemType.QUEST: "任务物品"
}

func _ready() -> void:
	super._ready()
	_update_display()

## 更新显示
func _update_display() -> void:
	if not is_node_ready() or not item_instance:
		hide()
		return
		
	show()
	
	# 更新名称（带颜色）
	var name_text = "[color=%s]%s[/color]" % [
		item_instance.item_data.get_rarity_color().to_html(),
		item_instance.item_data.get_localized_name()
	]
	if item_instance.enhancement_level > 0:
		name_text += " +%d" % item_instance.enhancement_level
	name_label.text = name_text
	
	# 更新类型
	type_label.text = TYPE_NAMES[item_instance.item_data.type]
	
	# 更新描述
	description_label.text = item_instance.item_data.get_localized_description()
	
	# 更新效果
	_update_effects()
	
	# 更新价格
	price_label.text = str(item_instance.get_value()) + " 金币"

## 更新效果显示
func _update_effects() -> void:
	# 清除现有效果
	for child in effects_container.get_children():
		child.queue_free()
	
	var effects = item_instance.get_total_effects()
	for effect_name in effects:
		var value = effects[effect_name]
		var effect_label = Label.new()
		
		# 格式化效果文本
		var text = ""
		match effect_name:
			"attack":
				text = "攻击力: +%d" % value
			"defense":
				text = "防御力: +%d" % value
			"heal":
				text = "恢复生命值: %d" % value
			_:
				text = "%s: %s" % [effect_name, str(value)]
		
		effect_label.text = text
		effects_container.add_child(effect_label)

## 设置位置
func set_tip_position(global_pos: Vector2) -> void:
	# 确保提示框不会超出屏幕边界
	var screen_size = get_viewport_rect().size
	var tip_size = size
	
	var final_pos = global_pos
	
	if final_pos.x + tip_size.x > screen_size.x:
		final_pos.x = screen_size.x - tip_size.x
	
	if final_pos.y + tip_size.y > screen_size.y:
		final_pos.y = final_pos.y - tip_size.y
	
	global_position = final_pos
