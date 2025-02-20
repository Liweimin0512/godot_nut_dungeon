extends PresentationHandler
class_name ProjectileHandler

## 投射物处理器接口

func handle_effect(config: Dictionary, context: Dictionary) -> void:
	if not config.has("scene"):
		GASLogger.error("ProjectileHandler: projectile scene is empty")
		return
	
	var scene : PackedScene = config["scene"]
	if not scene:
		GASLogger.error("ProjectileHandler: failed to load projectile scene: {0}".format([scene]))
		return
	
	# 实例化投射物
	var projectile = scene.instantiate()
	if not projectile:
		return

	
	# 设置投射物属性
	var actor = context.get("caster", null)
	var targets := _get_targets(config, context)
	projectile.global_position = _get_start_position(actor, config)
	projectile.target_position = _get_target_position(targets[0], config)
	# 设置投射物表现的时间
	projectile.duration = config.get("duration", 0.5)

	# 添加到场景
	# projectile.set("config", config)
	actor.get_parent().add_child(projectile)

func _get_start_position(actor: Node, config: Dictionary) -> Vector2:
	var start_attachment_type : StringName = config.get("start_attachment_type", "")
	if not start_attachment_type.is_empty() and actor.has_method("get_attachment_node"):
		var attachment : Node2D = actor.get_attachment_node(start_attachment_type)
		if attachment:
			return attachment.global_position
	return actor.global_position

func _get_target_position(target: Node, config: Dictionary) -> Vector2:
	var target_attachment_type : StringName = config.get("target_attachment_type", "")
	if not target_attachment_type.is_empty() and target.has_method("get_attachment_node"):
		var attachment : Node2D = target.get_attachment_node(target_attachment_type)
		if attachment:
			return attachment.global_position
	return target.global_position

class ProjectileConfig:
	extends RefCounted

	var scene : String = ""
	var speed : float = 500.0
	var target : Node = null

	func to_config() -> Dictionary:
		return {
			"scene": scene,
			"speed": speed,
			"target": target
		}
	
	static func from_config(config: Dictionary) -> ProjectileConfig:
		var projectile_config = ProjectileConfig.new()
		projectile_config.scene = config.get("scene", "")
		projectile_config.speed = config.get("speed", 500.0)
		projectile_config.target = config.get("target", null)
		return projectile_config
