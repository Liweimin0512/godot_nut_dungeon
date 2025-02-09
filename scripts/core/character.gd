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
@onready var character_logic : CharacterLogic = $CharacterLogic:
	get:
		if character_logic:
			return character_logic
		return $CharacterLogic

## 角色数据
@export var _character_config: CharacterModel
## 角色阵营
@export var character_camp: CombatDefinition.COMBAT_CAMP_TYPE = CombatDefinition.COMBAT_CAMP_TYPE.PLAYER:
	get:
		return _character_config.camp
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
	if not _character_config:
		push_error("character config is null")
		get_parent().remove_child(self)
		queue_free()
		return
		
	# 设置外观
	_setup_appearance()

	# 设置状态栏
	_setup_status()

func initialize(config: CharacterModel) -> void:
	_character_config = config

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

func _setup_status() -> void:
	if w_status:
		w_status.setup(character_logic.ability_component, character_logic.ability_resource_component)

func _on_animation_finished(anim_name: StringName) -> void:
	animation_finished.emit(anim_name)

func _to_string() -> String:
	return character_name if character_name else super.to_string()
