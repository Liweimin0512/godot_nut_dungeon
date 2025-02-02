extends ItemAbility
class_name BuffAbility

## 增益技能
## 用于提供属性增益的道具技能

# 导出变量
@export var buff_duration: float = 0.0  # 增益持续时间，0表示永久

# 内部变量
var _buff_effects: Array[GameplayEffect]

func _activate(payload: Dictionary) -> void:
	# 检查消耗品
	if not item_instance:
		return
		
	# 获取目标
	var target = payload.get("target", owner)
	if not target:
		return
		
	# 应用效果
	if buff_duration > 0:
		_apply_temporary_effects(target)
	else:
		apply_effects(target)
	
	# 播放效果
	_play_effects(target)
	
	# 完成技能
	end_ability()

## 应用临时效果
func _apply_temporary_effects(target: Node) -> void:
	var ability_system = target.get_node_or_null("AbilitySystemComponent")
	if not ability_system:
		return
		
	for effect_name in effects:
		var value = effects[effect_name]
		var effect = GameplayEffect.new()
		effect.duration = buff_duration
		
		match effect_name:
			"attack":
				effect.modifiers = {
					"attack": GameplayEffectModifier.new(
						GameplayEffectModifier.ModifierOperation.ADD,
						value
					)
				}
			"defense":
				effect.modifiers = {
					"defense": GameplayEffectModifier.new(
						GameplayEffectModifier.ModifierOperation.ADD,
						value
					)
				}
			_:
				continue
		
		ability_system.apply_gameplay_effect_to_self(effect)
		_buff_effects.append(effect)

## 播放效果
func _play_effects(target: Node) -> void:
	# TODO: 添加增益特效
	pass

## 移除效果
func _remove_effects() -> void:
	for effect in _buff_effects:
		effect.remove()
	_buff_effects.clear()
