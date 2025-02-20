extends PresentationHandler
class_name AnimationHandler


func handle_effect(config: Dictionary, context: Dictionary) -> void:
	var animation_config : AnimationConfig = AnimationConfig.from_config(config)
	if not animation_config:
		return

	var targets : Array[Node] = _get_targets(config, context)
	if targets.is_empty():
		return
	for target in targets:
		target.play_animation(animation_config.anim_name, animation_config.blend_time, animation_config.custom_speed)

class AnimationConfig:
	var anim_name : String
	var blend_time : float = 0.0
	var custom_speed : float = 1.0

	func _init(p_anim_name : String, p_blend_time : bool = 0.0, p_custom_speed : float = 1.0) -> void:
		anim_name = p_anim_name
		blend_time = p_blend_time
		custom_speed = p_custom_speed
	
	func to_config() -> Dictionary:
		return {
			"animation": anim_name,
			"blend_time": blend_time,
			"custom_speed": custom_speed
		}
	
	static func from_config(config : Dictionary) -> AnimationConfig:
		if config.get("animation", "").is_empty():
			GASLogger.error("AnimationHandler: animation name is empty")
			return null
		return AnimationConfig.new(
				config.get("animation", ""),
				config.get("blend_time", 0.0),
				config.get("custom_speed", 1))
