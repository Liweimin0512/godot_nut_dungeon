extends Node
class_name CombatPresenter

## 战斗表现控制器，负责处理战斗中的视觉效果和动画

const COMBAT_POST_PROCESS = preload("res://resources/shader/combat_post_process.gdshader")
# 常量定义
const COMBAT_POSITIONS = {
	"MELEE": {
		"actor": {
			"left": Vector2(-200, 240),
			"right": Vector2(200, 240),
			"scale": Vector2(1.8, 1.8),
			"action_offset": Vector2(50, 0),
		},
		"target": {
			"left": Vector2(-100, 240),
			"right": Vector2(100, 240),
			"scale": Vector2(1.6, 1.6),
			"action_offset": Vector2(-20, 0)
		},
		"camera":{
			"zoom": Vector2(1.3, 1.3),
			"offset": Vector2(30, -20),
		},
	},
	"RANGED": {
		"actor": {
			"left": Vector2(-300, 240),
			"right": Vector2(300, 240),
			"scale": Vector2(1.7, 1.7),
			"action_offset": Vector2(-30, 0)
		},
		"target": {
			"left": Vector2(-100, 240),
			"right": Vector2(100, 240),
			"scale": Vector2(1.5, 1.5),
			"action_offset": Vector2(-30, 0)
		},
		"camera":{
			"zoom": Vector2(1.3, 1.3),
			"offset": Vector2.ZERO,
		},
	},
	"SELF": {
		"actor": {
			"position": Vector2(0, 240),
			"scale": Vector2(1.8, 1.8),
			"action_offset": Vector2(0, 0),
		},
		"camera":{
			"zoom": Vector2(1.4, 1.4),
			"offset": Vector2(0, -20),
		},
	},
	"ALLY":{
		"actor": {
			"left": Vector2(-150, 240),
			"right": Vector2(150, 240),
			"scale": Vector2(1.5, 1.5),
			"action_offset": Vector2(-30, 0)
		},
		"target": {
			"left": Vector2(-50, 240),
			"right": Vector2(50, 240),
			"scale": Vector2(1.7, 1.7),
			"action_offset": Vector2(0, -20)
		},
		"camera":{
			"zoom": Vector2(1.3, 1.3),
			"offset": Vector2(0, -20),
		},
	}
}

# 节点引用
@export var action_layer: CanvasLayer					## 行动层
@export var camera: Camera2D							## 摄像机
@export var post_process: ColorRect						## 后处理

# 属性
var _original_parents: Dictionary = {}					## 原始父节点
var _original_positions: Dictionary = {}				## 原始位置
var _original_scales: Dictionary = {}					## 原始缩放
var _current_action: CombatAction = null					## 当前行动

# 系统引用
@onready var _time_manager : CoreSystem.TimeManager:
	get:
		return CoreSystem.time_manager

func _ready() -> void:
	# 订阅战斗系统事件
	CombatSystem.combat_action_started.subscribe(_on_combat_action_started)
	CombatSystem.combat_action_executed.subscribe(_on_combat_action_executed)
	CombatSystem.combat_action_ended.subscribe(_on_combat_action_ended)
	
	## 订阅技能系统时间


	# 初始化后处理shader
	_setup_post_process()

## 创建后处理shader
func _setup_post_process() -> void:
	# 创建后处理shader
	post_process.material = ShaderMaterial.new()
	post_process.material.shader = COMBAT_POST_PROCESS


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
func _move_units_to_combat_position(action: CombatAction) -> void:
	var combat_type = action.get_type_string()
	var positions = COMBAT_POSITIONS[combat_type]
	
	if action.is_self():
		# 自身技能特殊处理
		var tween = create_tween()
		tween.set_parallel(true)
		
		tween.tween_property(action.actor, "global_position",
			positions.actor.position, action.duration)
		tween.tween_property(action.actor, "scale",
			positions.actor.scale, action.duration)
			
		await tween.finished
		return
	
	var action_from_left = action.actor.global_position.x < _calculate_targets_center(action.targets).x
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 移动行动者
	tween.tween_property(action.actor, "global_position",
		positions.actor.left if action_from_left else positions.actor.right,
		action.duration)
	tween.tween_property(action.actor, "scale",
		positions.actor.scale, action.duration)
	
	# 移动目标们
	var target_count = action.targets.size()
	for i in target_count:
		var target = action.targets[i]
		var target_position = _calculate_target_position(
			positions.target.right if action_from_left else positions.target.left,
			target_count, i
		)
		
		tween.tween_property(target, "global_position",
			target_position, action.duration)
		tween.tween_property(target, "scale",
			positions.target.scale, action.duration)
	
	await tween.finished


## 执行攻击动作
func _execute_combat_action(action: CombatAction, duration: float = 0.3) -> void:
	var combat_type := action.get_type_string()
	var positions = COMBAT_POSITIONS[combat_type]
	
	if action.is_self():
		# 自身技能特殊处理
		var tween = create_tween()
		tween.set_parallel(true)
		
		# 简单的上浮动画
		tween.tween_property(action.actor, "position:y",
			action.actor.position.y - 30, action.duration)
		tween.tween_property(camera, "offset",
			positions.camera.offset, action.duration)
		
		await tween.finished
		return
	
	var action_from_left = action.actor.global_position.x < _calculate_targets_center(action.targets).x
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 1. 行动者移动
	var actor_offset = positions.actor.action_offset
	if not action_from_left:
		actor_offset.x *= -1
	tween.tween_property(action.actor, "position",
		action.actor.position + actor_offset, action.duration)
	
	# 2. 目标移动
	for target in action.targets:
		var target_offset = positions.target.action_offset
		if not action_from_left:
			target_offset.x *= -1
		tween.tween_property(target, "position",
			target.position + target_offset, action.duration)
	
	# 3. 摄像机跟随
	var camera_offset = positions.camera.offset
	if not action_from_left:
		camera_offset.x *= -1
	tween.tween_property(camera, "offset",
		camera_offset, action.duration)
	
	await tween.finished


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
func _setup_camera_for_combat(action: CombatAction, duration: float = 0.3) -> void:
	if action.is_self():
		# 自身技能时摄像机聚焦到施法者
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(camera, "global_position", action.actor.global_position, duration)
		tween.tween_property(camera, "zoom", Vector2(1.4, 1.4), duration)
		return
		
	# 计算目标中心点
	var targets_center = _calculate_targets_center(action.targets)
	var mid_point = (action.actor.global_position + targets_center) / 2
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(camera, "global_position", mid_point, duration)
	
	# 根据目标数量调整缩放
	var zoom_scale = 1.2
	if action.targets.size() > 1:
		zoom_scale = 1.1  # 多目标时略微拉远摄像机
	tween.tween_property(camera, "zoom", Vector2(zoom_scale, zoom_scale), duration)


## 重置摄像机
func _reset_camera(duration: float = 0.3) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(camera, "global_position", Vector2.ZERO, duration)
	tween.tween_property(camera, "zoom", Vector2.ONE, duration)


## 应用后处理效果
func _apply_post_process_effect(enable: bool, duration: float = 0.3) -> void:
	var tween = create_tween()
	if enable:
		tween.tween_property(post_process.material, 
			"shader_parameter/blur_amount", 2.0, duration)
		tween.tween_property(post_process.material,
			"shader_parameter/vignette_intensity", 0.3, duration)
		tween.tween_property(post_process.material,
			"shader_parameter/brightness", 0.9, duration)
	else:
		tween.tween_property(post_process.material,
			"shader_parameter/blur_amount", 0.0, duration)
		tween.tween_property(post_process.material,
			"shader_parameter/vignette_intensity", 0.0, duration)
		tween.tween_property(post_process.material,
			"shader_parameter/brightness", 1.0, duration)


# 计算多个目标的位置
func _calculate_target_position(base_position: Vector2, total: int, index: int) -> Vector2:
	if total == 1:
		return base_position
		
	var spread = 60.0  # 目标之间的间距
	var total_width = spread * (total - 1)
	var start_x = base_position.x - total_width / 2
	
	return Vector2(start_x + spread * index, base_position.y)


# 计算目标中心点
func _calculate_targets_center(targets: Array) -> Vector2:
	var center = Vector2.ZERO
	for target in targets:
		center += target.global_position
	return center / targets.size()


# 获取战斗范围
func _get_combat_bounds(action: CombatAction) -> Rect2:
	var bounds = Rect2(action.actor.global_position, Vector2.ZERO)
	
	for target in action.targets:
		bounds = bounds.expand(target.global_position)
	
	return bounds

# 计算多目标中心点
func _calculate_multi_target_center(targets: Array) -> Vector2:
	var center = Vector2.ZERO
	for target in targets:
		center += target.global_position
	return center / targets.size()


## 播放音效
func _play_sound(sound_resource: AudioStream) -> void:
	var audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.stream = sound_resource
	audio_player.play()
	await audio_player.finished
	audio_player.queue_free()


## 播放特效
func _spawn_effect(effect_scene: PackedScene, position: Vector2) -> void:
	var effect = effect_scene.instantiate()
	action_layer.add_child(effect)
	effect.global_position = position
	
	if effect.has_method("play"):
		effect.play()
	
	if effect.has_signal("finished"):
		await effect.finished
	else:
		await get_tree().create_timer(2.0).timeout
	
	effect.queue_free()


func _on_combat_action_started(action: CombatAction) -> void:
	_current_action = action
	
	# 1. 移动单位到战斗层
	_move_units_to_action_layer(action)
	
	# 2. 调整时间速度
	_time_manager.set_time_scale(0.5)  # 减速效果
	
	# 3. 移动单位到战斗位置
	await _move_units_to_combat_position(action)
	
	# 4. 设置摄像机
	_setup_camera_for_combat(action)
	
	# 5. 应用后处理效果
	_apply_post_process_effect(true)


func _on_combat_action_executed(action: CombatAction, duration: float = 0.3) -> void:
	await _execute_combat_action(action, duration)

	# 根据行动类型添加不同强度的震动
	var trauma = 0.0
	match action.action_type:
		CombatAction.ActionType.MELEE:
			trauma = 0.5  # 近战攻击震动更强
		CombatAction.ActionType.RANGED:
			trauma = 0.3  # 远程攻击震动适中
		CombatAction.ActionType.SELF:
			trauma = 0.2  # 自身技能轻微震动
		CombatAction.ActionType.ALLY:
			trauma = 0.2  # 友方技能轻微震动

	# 添加摄像机震动
	camera.add_trauma(trauma)


func _on_combat_action_ended(_action: CombatAction) -> void:
	# 1. 恢复单位位置
	await _restore_units_state()
	
	# 2. 重置摄像机
	_reset_camera()
	
	# 3. 移除后处理效果
	_apply_post_process_effect(false)
	
	# 4. 恢复时间速度
	_time_manager.set_time_scale(1.0)
