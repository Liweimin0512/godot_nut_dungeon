extends Control
class_name TurnStatus

# 常量
const MAX_DISPLAY_UNITS = 4  			## 最多显示的单位数量
const UNIT_SPACING = 10      			## 单位图标间距
const ANIMATION_DURATION = 0.3  		## 动画持续时间

# 节点引用
@onready var label_turn_count: Label = %LabelTurnCount
@onready var order_container: HBoxContainer = %OrderContainer
@onready var tween: Tween
@onready var ui_widget_component: UIWidgetComponent = $UIWidgetComponent

var _current_units : Array

func _ready() -> void:
	CombatSystem.combat_turn_started.subscribe(_on_turn_started)
	CombatSystem.combat_action_ended.subscribe(_on_action_ended)

## 私有方法

func _update_display() -> void:
	_set_turn()
	_update_order()

## 设置当前回合数
func _set_turn() -> void:
	var turn_number := CombatSystem.current_turn
	if not is_node_ready():
		await ready
	label_turn_count.text = "第%d回合" % turn_number
	
	# 添加标签出现动画
	tween = create_tween()
	tween.tween_property(label_turn_count, "modulate:a", 0.0, 0.0)
	tween.tween_property(label_turn_count, "modulate:a", 1.0, ANIMATION_DURATION)


## 更新行动顺序显示
func _update_order() -> void:
	var units := CombatSystem.get_action_order()

	# 清除现有的单位图标
	for child in order_container.get_children():
		child.queue_free()
	
	_current_units = units.duplicate()
	
	# 创建新的单位图标（最多显示MAX_DISPLAY_UNITS个）
	for i in range(min(units.size(), MAX_DISPLAY_UNITS)):
		var unit : Character = units[i]
		var icon : CharacterIcon = ui_widget_component.create_widget("character_icon", order_container)
		
		# 设置图标属性
		icon.setup(unit)
		
		# 添加出现动画
		icon.modulate.a = 0.0
		tween = create_tween()
		tween.tween_property(icon, "modulate:a", 1.0, ANIMATION_DURATION).set_delay(i * 0.1)
		
		# 如果是当前行动者，添加高亮效果
		if i == 0:
			_highlight_current_unit(icon)

# 移除第一个单位（当前行动者完成行动后调用）
func _remove_current_unit() -> void:
	if _current_units.is_empty():
		return
	
	# 移除第一个单位
	_current_units.pop_front()
	
	# 如果还有单位图标
	if not order_container.get_children().is_empty():
		var first_icon = order_container.get_child(0)
		
		# 创建消失动画
		tween = create_tween()
		tween.tween_property(first_icon, "modulate:a", 0.0, ANIMATION_DURATION)
		tween.tween_callback(first_icon.queue_free)
		
		# 移动其他图标
		for i in range(1, order_container.get_child_count()):
			var icon = order_container.get_child(i)
			var target_position = icon.position - Vector2(icon.size.x + UNIT_SPACING, 0)
			tween.parallel().tween_property(icon, "position", target_position, ANIMATION_DURATION)
		
		# 如果还有新的单位要显示
		if _current_units.size() >= MAX_DISPLAY_UNITS:
			var new_unit = _current_units[MAX_DISPLAY_UNITS - 1]
			var new_icon = ui_widget_component.create_widget("character_icon", order_container)
			new_icon.setup(new_unit)
			
			# 设置初始位置和透明度
			new_icon.modulate.a = 0.0
			new_icon.position.x = (MAX_DISPLAY_UNITS - 1) * (new_icon.size.x + UNIT_SPACING)
			
			# 创建出现动画
			tween.parallel().tween_property(new_icon, "modulate:a", 1.0, ANIMATION_DURATION)

# 高亮显示当前行动单位
func _highlight_current_unit(icon: Node) -> void:
	# 创建呼吸动画效果
	tween = create_tween()
	tween.set_loops()  # 设置循环
	tween.tween_property(icon, "modulate:v", 1.2, 0.5)
	tween.tween_property(icon, "modulate:v", 1.0, 0.5)

## 当回合准备好时调用
func _on_turn_started() -> void:
	_update_display()
	
## 当行动结束后
func _on_action_ended() -> void:
	_update_display()
#
#func _on_ui_widget_component_initialized(_data: Dictionary) -> void:
	#_update_display()
#
#func _on_ui_widget_component_updated(_data: Dictionary) -> void:
	#_update_display()
