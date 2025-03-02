extends Node
class_name CombatPresenter

## 战斗表现控制器，负责处理战斗中的视觉效果和动画

const COMBAT_POST_PROCESS : Shader = preload("res://resources/shader/combat_post_process.gdshader")

# 节点引用
@export var action_layer: CanvasLayer					## 行动层
@export var camera: Camera2D							## 摄像机
@export var post_process: ColorRect						## 后处理

## y坐标偏移
@export var y_offset: float = 440
## 远程位置偏移
@export var range_offset: float = 260
## 近战位置偏移
@export var melee_offset: float = 150
## 单个角色偏移
@export var single_offset: float = 180
## 行动者放大倍数
@export var actor_scale_multiplier: float = 1.8
## 目标放大倍数
@export var target_scale_multiplier: float = 1.6
## 近战摄像机缩放
@export var melee_camera_zoom: Vector2 = Vector2(1.4, 1.4)
## 远程摄像机缩放
@export var range_camera_zoom: Vector2 = Vector2(1.2, 1.2)
## 近战摄像机偏移
@export var melee_camera_offset: Vector2 = Vector2(30, -20)
## 远程摄像机偏移
@export var range_camera_offset: Vector2 = Vector2(0, 0)
## 近战移动偏移
@export var melee_move_offset: Vector2 = Vector2(30, 20)
## 远程移动偏移
@export var range_move_offset: Vector2 = Vector2(50, 0)

@export var blur_amount : float = 3.0
@export var vignette_intensity : float = 0.5
@export var brightness : float = 0.7

# 属性
var _original_parents: Dictionary = {}					## 原始父节点
var _original_positions: Dictionary = {}				## 原始位置
var _original_scales: Dictionary = {}					## 原始缩放
var _current_action: CombatAction = null				## 当前行动
var _screen_center : Vector2 = Vector2.ZERO				## 屏幕中心位置

## 效果处理器映射
var _action_handlers: Dictionary

var _logger : CoreSystem.Logger = CoreSystem.logger

# 系统引用
@onready var _time_manager : CoreSystem.TimeManager:
	get:
		return CoreSystem.time_manager

func _ready() -> void:
	# 订阅战斗系统事件
	CombatSystem.combat_action_executing.subscribe(_on_combat_action_executing)
	CombatSystem.combat_action_executed.subscribe(_on_combat_action_executed)
	
	## 订阅技能系统事件
	AbilitySystem.presentation_manager.presentation_requested.connect(_on_presentation_requested)

	# 创建后处理shader
	post_process.material = ShaderMaterial.new()
	post_process.material.shader = COMBAT_POST_PROCESS
	# 初始化shader参数
	post_process.material.set_shader_parameter("blur_amount", 0.0)
	post_process.material.set_shader_parameter("vignette_intensity", 0.0)
	post_process.material.set_shader_parameter("brightness", 1.0)
	
	_screen_center = Vector2(camera.get_viewport_rect().size.x / 2, 0)

	_setup_action_handlers()

func _setup_action_handlers() -> void:
	_action_handlers["animation"] = AnimationHandler.new()
	_action_handlers["projectile"] = ProjectileHandler.new()
	_action_handlers["particle"] = ParticleHandler.new()
	_action_handlers["sound"] = SoundHandler.new()
	_action_handlers["camera"] = CameraHandler.new(camera)

## 创建后处理shader
func _setup_post_process() -> void:
	# 创建后处理shader
	post_process.material = ShaderMaterial.new()
	post_process.material.shader = COMBAT_POST_PROCESS
	print("blur_amount", post_process.material.get_shader_parameter("blur_amount"))


## 获取战斗类型
func _get_combat_type(action: CombatAction) -> String:
	return action.get_type_string()


## 保存原始状态并移动到行动层
func _move_units_to_action_layer(action: CombatAction) -> void:
	var units = [action.actor]  # 首先添加行动者
	units.append_array(action.targets)  # 添加所有目标
	
	for unit in units:
		_original_parents[unit] = unit.get_parent()
		_original_positions[unit] = unit.global_position
		_original_scales[unit] = unit.scale
		
		# 保持全局变换不变的情况下改变父节点
		var global_pos = unit.global_position
		_original_parents[unit].remove_child(unit)
		action_layer.add_child(unit)
		unit.global_position = global_pos


## 移动单位到战斗位置
func _move_units_to_combat_position(action: CombatAction, duration : float) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	var action_from_left = action.actor.global_position.x < _calculate_targets_center(action.targets).x
	
	# 移动行动者
	var actor_position = _calculate_actor_position(action, action_from_left)
	tween.tween_property(action.actor, "global_position", actor_position, duration)
	tween.tween_property(action.actor, "scale", actor_scale_multiplier * action.actor.scale, duration)
	
	# 移动目标们
	var target_count = action.targets.size()
	var target_base_position = _get_mirrored_position(actor_position, _screen_center.x)
	for i in target_count:
		var target = action.targets[i]
		var target_position = _calculate_target_position(target_base_position, target_count, i, action_from_left)
		
		tween.tween_property(target, "global_position", target_position, duration)
		tween.tween_property(target, "scale", target.scale * target_scale_multiplier, duration)
	
	await tween.finished


## 获取自身行动位置
func _calculate_actor_position(action: CombatAction, action_from_left: bool) -> Vector2:
	var actor_position : Vector2 = _screen_center + Vector2(0, y_offset)
	if action.is_self():
		return actor_position

	if action.is_melee() or action.is_ally():
		actor_position.x -= melee_offset if action_from_left else -melee_offset
	elif action.is_ranged():
		actor_position.x -= range_offset if action_from_left else -range_offset
		
	return actor_position


## 获取镜像位置
func _get_mirrored_position(point: Vector2, mirror_x: float) -> Vector2:
	return Vector2(
		2 * mirror_x - point.x,
		point.y
	)


# 计算多个目标的位置
func _calculate_target_position(base_position: Vector2, total: int, index: int, action_from_left: bool) -> Vector2:
	if total == 1:
		return base_position
		
	var total_width = single_offset * (total - 1)
	var start_x = base_position.x - total_width / 2
	
	return Vector2(start_x + single_offset * index * (1 if action_from_left else -1), base_position.y)


# 计算目标中心点
func _calculate_targets_center(targets: Array) -> Vector2:
	if targets.is_empty():
		return Vector2.ZERO
	var center = Vector2.ZERO
	for target in targets:
		center += target.global_position
	return center / targets.size()


## 执行攻击动作
func _execute_combat_action(action: CombatAction, duration) -> void:
	var action_from_left = action.actor.global_position.x < _calculate_targets_center(action.targets).x
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 1. 行动者移动
	var actor_move_offset = _calculate_action_offset(action, action_from_left)
	tween.tween_property(action.actor, "position",
		action.actor.position + actor_move_offset, duration)
	
	# 2. 目标移动
	var target_move_offset = melee_move_offset if action.is_melee() or action.is_ally() else range_move_offset
	target_move_offset *= 1 if action_from_left else -1
	for target in action.targets:
		tween.tween_property(target, "position", target.position + target_move_offset, duration)
	
	# 3. 摄像机跟随
	var camera_offset = melee_camera_offset if action.is_melee() or action.is_ally() else range_camera_offset
	if not action_from_left:
		camera_offset.x *= -1
	tween.tween_property(camera, "offset", camera_offset, duration)
	
	await tween.finished


## 计算行动者偏移
func _calculate_action_offset(action: CombatAction, action_from_left: bool) -> Vector2:
	if action.is_self():
		return Vector2.ZERO
	
	if action.is_melee() or action.is_ally():
		return melee_move_offset if action_from_left else -melee_move_offset
	elif action.is_ranged():
		return -range_move_offset if action_from_left else range_move_offset
	
	return Vector2.ZERO


## 恢复单位状态
func _restore_units_state() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	for unit in _original_parents.keys():
		# 1. 先恢复位置和缩放
		tween.tween_property(unit, "global_position",
			_original_positions[unit], 0.3)
		tween.tween_property(unit, "scale",
			_original_scales[unit], 0.3)
	
	await tween.finished
	
	# 2. 再恢复父节点
	for unit in _original_parents.keys():
		action_layer.remove_child(unit)
		_original_parents[unit].add_child(unit)
		unit.global_position = _original_positions[unit]
	
	_original_parents.clear()
	_original_positions.clear()
	_original_scales.clear()


## 设置战斗行动视角摄像机
func _setup_camera_for_combat(action: CombatAction, duration : float) -> void:
	var tween = create_tween()
	tween.set_parallel(true)

	var camera_zoom : Vector2 = melee_camera_zoom if action.is_melee() or action.is_ally() else range_camera_zoom
	tween.tween_property(camera, "zoom", camera_zoom, duration)

	await tween.finished


## 重置摄像机
func _reset_camera() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(camera, "global_position", camera.get_viewport_rect().size/ 2, 0.3)
	tween.tween_property(camera, "zoom", Vector2.ONE, 0.3)
	camera.reset_shake()

## 应用后处理效果
func _apply_post_process_effect(enable: bool, duration: float) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	if enable:
		tween.tween_property(post_process.material, "shader_parameter/blur_amount", blur_amount, duration)
		tween.tween_property(post_process.material, "shader_parameter/vignette_intensity", vignette_intensity, duration)
		tween.tween_property(post_process.material, "shader_parameter/brightness", brightness, duration)
	else:
		tween.tween_property(post_process.material, "shader_parameter/blur_amount", 0.0, duration)
		tween.tween_property(post_process.material, "shader_parameter/vignette_intensity", 0.0, duration)
		tween.tween_property(post_process.material, "shader_parameter/brightness", 1.0, duration)

func _on_combat_action_executing() -> void:
	_logger.debug("开始执行行动:%s" % _current_action)

	_current_action = CombatSystem.current_action
	
	# 1. 移动单位到战斗层
	_move_units_to_action_layer(_current_action)
	
	# 2. 调整时间速度
	_time_manager.set_time_scale(0.5)  # 减速效果
	
	# 3. 移动单位到战斗位置
	_move_units_to_combat_position(_current_action, 0.5)
	
	# 4. 设置摄像机
	_setup_camera_for_combat(_current_action, 0.5)
	
	# 5. 应用后处理效果
	_apply_post_process_effect(true, 0.5)

	# 6.执行战斗动作
	_execute_combat_action(_current_action, 0.5)


func _on_combat_action_executed() -> void:
	_logger.debug("执行行动完成:%s" % _current_action)
	# 1. 恢复单位位置
	await _restore_units_state()
	
	# 2. 重置摄像机
	_reset_camera()
	
	# 3. 移除后处理效果
	#var action := CombatSystem.current_action
	_apply_post_process_effect(false, 0.5)
	
	# 4. 恢复时间速度
	_time_manager.set_time_scale(1.0)

## 处理技能表现效果
func _on_presentation_requested(type: StringName, config: Dictionary, context: Dictionary) -> void:
	if type == "effect":
		type = config.get("type", "effect")
	if not _action_handlers.has(type):
		GASLogger.error("Invalid effect type: " + type)
		return
	var handler = _action_handlers[type]
	if handler.has_method("handle_effect"):
		handler.handle_effect(config, context)
