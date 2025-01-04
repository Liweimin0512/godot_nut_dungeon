extends RefCounted
class_name ProjectileVFXManager

## 投射物视觉效果管理器

## 投射物视觉效果场景字典
@export var _projectile_scenes: Dictionary[String, PackedScene]

## 投射物视觉效果字典
var _active_vfx: Dictionary[String, Node] = {}

## 场景树Root
var _scene_root: Node

## 初始化
func setup(scene_root: Node) -> void:
    _scene_root = scene_root
    # 监听逻辑层信号
    ProjectileSystem.projectile_created.connect(_on_projectile_created)
    ProjectileSystem.projectile_moved.connect(_on_projectile_moved)
    ProjectileSystem.projectile_hit.connect(_on_projectile_hit)
    ProjectileSystem.projectile_destroyed.connect(_on_projectile_destroyed)

## 注册投射物视觉效果
func register_projectile_vfx(projectile_id: String, vfx_scene: PackedScene) -> void:
    _projectile_scenes[projectile_id] = vfx_scene

func _on_projectile_created(projectile_id: String, data: Dictionary) -> void:
    var projectile_type = data.get("type", "fireball")
    if not _projectile_scenes.has(projectile_type):
        return
    
    # 创建视觉效果实例
    var vfx = _projectile_scenes[projectile_type].instantiate()
    _scene_root.add_child(vfx)
    
    # 设置初始位置
    vfx.global_position = data.start_position
    vfx.rotation = data.velocity.angle()
    
    # 存储引用
    _active_vfx[projectile_id] = vfx

func _on_projectile_moved(projectile_id: String, position: Vector2, rotation: float) -> void:
    var vfx = _active_vfx.get(projectile_id)
    if vfx:
        vfx.global_position = position
        vfx.rotation = rotation

func _on_projectile_hit(projectile_id: String, hit_data: Dictionary) -> void:
    var vfx = _active_vfx.get(projectile_id)
    if vfx:
        # 播放命中特效
        vfx.play_hit_effect(hit_data)

func _on_projectile_destroyed(projectile_id: String) -> void:
    var vfx = _active_vfx.get(projectile_id)
    if vfx:
        vfx.queue_free()
        _active_vfx.erase(projectile_id)

## 清理资源
func cleanup() -> void:
    for vfx in _active_vfx.values():
        if is_instance_valid(vfx):
            vfx.queue_free()
    _active_vfx.clear()