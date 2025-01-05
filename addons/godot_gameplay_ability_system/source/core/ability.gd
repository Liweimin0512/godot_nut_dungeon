extends Resource
class_name Ability

## 技能类，代表一个技能，包括技能名称、描述、图标、触发器、等级、效果等

## 技能名称
@export var ability_name : StringName = ""
## 技能描述
@export var ability_description: String = ""
## 技能在UI中显示的图标
@export var icon: Texture2D
## 技能效果树root节点
@export var effect_tree_root: AbilityEffectNode
## 所属技能组件
var _ability_component: AbilityComponent
## 技能上下文
var _context : Dictionary

signal cast_finished

## 应用技能
func apply(ability_component: AbilityComponent, context: Dictionary) -> void:
	_ability_component = ability_component
	_context = context
	_apply(context)

## 移除技能
func remove() -> void:
	effect_tree_root.revoke()
	_remove()

## 执行技能
func cast(context: Dictionary) -> bool:
	_context.merge(context, true)
	return await _cast(_context)

func _apply(context: Dictionary) -> void:
	pass

func _remove() -> void:
	pass

func _cast(context: Dictionary) -> bool:
	if not effect_tree_root: return false
	var result = await effect_tree_root.execute(_context)
	if result == AbilityEffectNode.STATUS.SUCCESS:
		GASLogger.info("技能{0}执行成功".format([self]))
		cast_finished.emit()
		return true
	GASLogger.error("技能{0}执行失败".format([self]))
	return false

func _to_string() -> String:
	return ability_name
