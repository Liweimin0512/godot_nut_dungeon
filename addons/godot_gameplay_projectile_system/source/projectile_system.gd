extends Node
class_name ProjectileSystem

## 逻辑层的投射物系统单例, 用于管理投射物的创建、移动、碰撞和销毁
## 投射物系统是独立于其他系统的, 它不依赖于任何其他系统
## 技能系统、状态系统、AI系统等都可以使用投射物系统

## 可用投射物场景
var _projectile_scenes: Dictionary = {}
## 投射物数据
var active_projectiles: Dictionary = {}
## 投射物ID
var next_projectile_id: int = 0
## 投射物效果管理器
var _vfx_manager: ProjectileVFXManager = ProjectileVFXManager.new()
## 投射物行为工厂
var _behavior_factory: ProjectileBehaviorFactory = ProjectileBehaviorFactory.new()

## 投射物创建信号
signal projectile_created(projectile_id: String, data: Dictionary)
## 投射物移动信号
signal projectile_moved(projectile_id: String, position: Vector2, rotation: float)
## 投射物命中信号
signal projectile_hit(projectile_id: String, hit_data: Dictionary)
## 投射物销毁信号
signal projectile_destroyed(projectile_id: String)

## 初始化
func _enter_tree() -> void:
    _vfx_manager.setup(get_tree().root)
    _behavior_factory.setup()

## 处理投射物
func _process(delta: float) -> void:
    var to_remove = []
    
    # 更新所有投射物
    for id in active_projectiles:
        var proj = active_projectiles[id]
        
        # 更新位置
        proj.position += proj.velocity * delta
        proj.time_alive += delta
        
        # 发出移动信号
        projectile_moved.emit(id, proj.position, proj.velocity.angle())
        
        # 检查生命周期
        if proj.time_alive >= proj.lifetime:
            to_remove.append(id)
            
    # 移除过期的投射物
    for id in to_remove:
        destroy_projectile(id)

## 注册投射物
func register_projectile(projectile_id: String, projectile_scene: PackedScene) -> void:
    _projectile_scenes[projectile_id] = projectile_scene

## 创建投射物
func create_projectile(data: Dictionary) -> String:
    # 生成唯一ID
    var projectile_id = str(next_projectile_id)
    next_projectile_id += 1
    
    # 获取行为类型
    var behavior_type = data.get("behavior_type", "linear")
    var behavior = behavior_factory.create_behavior(behavior_type)
    
    # 存储投射物数据
    active_projectiles[projectile_id] = {
        "position": data.start_position,
        "velocity": data.velocity,
        "behavior": behavior,
        "behavior_data": data.get("behavior_data", {}),
        "lifetime": data.lifetime,
        "time_alive": 0.0
    }
    
    # 发出创建信号
    projectile_created.emit(projectile_id, data)
    return projectile_id

## 处理投射物碰撞
func handle_collision(projectile_id: String, target: Dictionary) -> void:
    var proj = active_projectiles.get(projectile_id)
    if not proj:
        return
        
    # 执行命中效果
    if proj.hit_effect:
        proj.hit_effect.execute({
            "target": target,
            "hit_point": proj.position
        })
    
    # 发出命中信号
    projectile_hit.emit(projectile_id, {
        "target": target,
        "position": proj.position
    })
    
    # 销毁投射物
    destroy_projectile(projectile_id)

## 销毁投射物
func destroy_projectile(projectile_id: String) -> void:
    if active_projectiles.has(projectile_id):
        active_projectiles.erase(projectile_id)
        projectile_destroyed.emit(projectile_id)