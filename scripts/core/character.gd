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

## 所在战斗位置
var combat_point : int = -1

## 角色名称
var character_name: String:
	get:
		if not _character_config:
			return ""
		return _character_config.character_name
	set(value):
		push_error("character_name is read-only")

var _event_bus : CoreSystem.EventBus:
	get:
		return CoreSystem.event_bus

## 角色信号
signal animation_finished(anim_name: StringName)
# signal attribute_changed(name: String, old_value: float, new_value: float)
# signal resource_changed(resource_name: String, old_value: float, new_value: float)

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
	_event_bus.subscribe("character_turn_prepared", _on_character_turn_prepared)
	
	# 设置组件
	_setup_components()


	# 设置状态栏
	_setup_status()

## 播放动画
func play_animation(anim_name: StringName, blend_time: float = 0.0, custom_speed: float = 1.0) -> void:
	if animation_player:
		animation_player.play(anim_name, blend_time, custom_speed)

# 内部方法

func _setup_components() -> void:
	ability_attribute_component.setup(_character_config.ability_attributes)
	ability_component.setup(_character_config.abilities, {"caster": combat_component})
	ability_resource_component.setup(_character_config.ability_resources, ability_component, ability_attribute_component)
	combat_component.setup(character_camp, combat_point)

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
	animation_finished.emit(anim_name)

## 战斗开始
func _on_character_combat_started() -> void:
	pass

## 回合开始
func _on_character_turn_started() -> void:
	pass

func _on_character_turn_prepared(combat: CombatComponent) -> void:
	if combat_component != combat:
		return
	if combat != combat_component:
		return
	print("character turn prepared")
	# combat.turn_prepare_end()
	_event_bus.push_event("character_turn_prepare_end", self)

func _to_string() -> String:
	return character_name if character_name else super.to_string()
