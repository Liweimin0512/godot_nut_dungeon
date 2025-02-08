extends Node2D
class_name Character

## 角色类，负责角色的基本功能和表现
## 包括：
## 1. 角色数据管理
## 2. 角色外观设置
## 3. 动画播放

## 组件引用
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var combat_component: CombatComponent = %CombatComponent
@onready var ability_component: AbilityComponent = %AbilityComponent
@onready var ability_resource_component: AbilityResourceComponent = %AbilityResourceComponent
@onready var ability_attribute_component: AbilityAttributeComponent = %AbilityAttributeComponent
@onready var w_status: W_Status = $W_Status

## 角色数据
@export var _character_config: CharacterModel
## 角色阵营
@export var character_camp: CombatDefinition.COMBAT_CAMP_TYPE = CombatDefinition.COMBAT_CAMP_TYPE.PLAYER:
	set(value):
		character_camp = value
		if combat_component:
			combat_component.combat_camp = value

@export var character_icon: Texture2D

## 角色名称
var character_name: String:
	get:
		if not _character_config:
			return ""
		return _character_config.character_name
	set(value):
		push_error("character_name is read-only")

## 角色信号
signal animation_finished(anim_name: StringName)
signal attribute_changed(name: String, old_value: float, new_value: float)
# signal resource_changed(resource_name: String, old_value: float, new_value: float)

func _ready() -> void:
	_connect_component_signals()

	# 通知各组件有新的角色数据
	_notify_model_updated()

	# 设置外观
	_setup_appearance()

	# 
	_setup_status()

## 初始化角色，在ready之前
func setup(model: CharacterModel) -> void:
	if not model:
		push_error("character model is null")
		return
		
	_character_config = model

## 播放动画
func play_animation(anim_name: StringName, blend_time: float = 0.0, custom_speed: float = 1.0) -> void:
	if animation_player:
		animation_player.play(anim_name, blend_time, custom_speed)

## 内部方法
func _setup_appearance() -> void:
	# 设置图标
	character_icon = _character_config.character_icon
	
	# 设置精灵位置
	$Sprite2D.position = _character_config.sprite_position
	if character_camp == CombatDefinition.COMBAT_CAMP_TYPE.ENEMY:
		$Sprite2D.flip_h = true
	
	# 设置动画
	_setup_animations()

func _setup_animations() -> void:
	if not animation_player:
		return
		
	animation_player.remove_animation_library("")
	animation_player.add_animation_library("", _character_config.animation_library)
	
	if not animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.connect(_on_animation_finished)

func _connect_component_signals() -> void:
	# 连接属性组件信号
	if ability_attribute_component:
		ability_attribute_component.attribute_changed.connect(
			func(atr_name: String, old_val: float, new_val: float):
				attribute_changed.emit(atr_name, old_val, new_val)
		)

func _notify_model_updated() -> void:
	# 通知各组件有新的角色数据
	if ability_attribute_component:
		ability_attribute_component.set_model_data(_character_config.ability_attributes)
	
	if ability_resource_component:
		ability_resource_component.set_model_data(_character_config.ability_resources)
	
	if ability_component:
		ability_component.set_model_data(_character_config.abilities)
	
	if combat_component:
		combat_component.set_model_data(character_camp)

func _setup_status() -> void:
	if w_status:
		w_status.setup(self)

func _on_animation_finished(anim_name: StringName) -> void:
	animation_finished.emit(anim_name)

func _to_string() -> String:
	return character_name if character_name else super.to_string()
