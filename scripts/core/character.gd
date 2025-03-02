extends Node2D
class_name Character

## 角色类，负责角色的基本功能和表现
## 包括：
## 1. 角色数据管理
## 2. 角色外观设置
## 3. 动画播放

## 组件引用
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var w_status: W_Status = $W_Status
@onready var ability_attribute_component: AbilityAttributeComponent = $AbilityAttributeComponent
@onready var ability_resource_component: AbilityResourceComponent = $AbilityResourceComponent
@onready var ability_component: AbilityComponent = $AbilityComponent
@onready var combat_component: CombatComponent = $CombatComponent
@onready var selector: TextureRect = $Selector
@onready var target_selector: TextureRect = $TargetSelector
@onready var _attachment_types: Dictionary[StringName, Marker2D] = {
	"head" : %head,
	"body" : %body,
	"feet" : %feet,
	"hand" : %hand,
}
## 角色数据
@export var _character_config: CharacterModel
## 角色阵营
@export var character_camp: CombatDefinition.COMBAT_CAMP_TYPE = CombatDefinition.COMBAT_CAMP_TYPE.PLAYER:
	get:
		return _character_config.camp
## 角色头像
@export var character_icon: Texture2D:
	get:
		return _character_config.character_icon
	set(_value):
		assert(false, "character_icon 是只读属性不允许赋值")

## 角色名称
var character_name: String:
	get:
		if not _character_config:
			return ""
		return _character_config.character_name
	set(value):
		push_error("character_name is read-only")
var can_select: bool = false

## 角色信号
signal animation_finished(anim_name: StringName)
signal pressed

func _ready() -> void:
	CombatSystem.combat_action_selecting.subscribe(_on_combat_action_selecting)
	selector.hide()
	target_selector.hide()


func initialize(config: CharacterModel) -> void:
	_character_config = config
	# 设置外观
	_setup_appearance()

	if not is_node_ready():
		# 如果没有成ready则等待ready完成后在继续执行
		await ready
	
	if not _character_config:
		push_error("character config is null")
		get_parent().remove_child(self)
		queue_free()
		return
	
	# 设置组件
	_setup_components()

	# 设置状态栏
	_setup_status()

	AbilitySystem.subscribe_ability_event("damage_completed", _on_damage_completed)
	
## 播放动画
func play_animation(anim_name: StringName, blend_time: float = 0.0, custom_speed: float = 1.0) -> void:
	if animation_player:
		animation_player.play(anim_name, blend_time, custom_speed)

## 获取粒子附着点
func get_attachment_node(attachment_name : StringName) -> Marker2D:
	if attachment_name.is_empty():
		return null
	return _attachment_types.get(attachment_name, null)


## 清除预选状态
func clear_preselect() -> void:
	selector.hide()


# 内部方法

func _setup_components() -> void:
	ability_attribute_component.setup(_character_config.ability_attributes)
	ability_component.setup(_character_config.abilities, {"caster": combat_component})
	ability_resource_component.setup(_character_config.ability_resources, ability_component, ability_attribute_component)
	combat_component.setup(character_camp)

func _setup_appearance() -> void:	
	# 设置精灵位置
	$Sprite2D.position = _character_config.sprite_position
	if character_camp == CombatDefinition.COMBAT_CAMP_TYPE.ENEMY:
		$Sprite2D.flip_h = true
	
	# 设置动画
	_setup_animations()

func _setup_animations() -> void:
	if not animation_player:
		animation_player = $AnimationPlayer
	
	# 设置动画库
	animation_player.remove_animation_library("")
	animation_player.add_animation_library("", _character_config.animation_library)
	if not animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.connect(_on_animation_finished)
	animation_player.play(&"idle")
	
func _setup_status() -> void:
	if w_status:
		w_status.setup(ability_component, ability_resource_component)

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name != &"die":
		play_animation(&"idle")
	animation_finished.emit(anim_name)

## 受击动作
func _on_damage_completed(damage_context: Dictionary) -> void:
	var damage_target : Node2D = damage_context.get("target", null)
	if not damage_target or damage_target != self:
		return
	
	play_animation(&"hit")


func _on_combat_action_selecting() -> void:
	var action_unit := CombatSystem.current_actor
	if action_unit != self:
		return
	selector.show()


func _on_area_2d_mouse_exited() -> void:
	target_selector.hide()


func _on_area_2d_mouse_entered() -> void:
	if can_select:
		target_selector.show()


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			pressed.emit()


func _to_string() -> String:
	return character_name if character_name else super.to_string()
