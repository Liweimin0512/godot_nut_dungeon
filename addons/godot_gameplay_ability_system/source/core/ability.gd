extends Resource
class_name Ability

## 技能基类，提供基础的技能系统功能

## 技能名称
@export var ability_name: StringName
## 技能描述
@export var ability_description: String
## 技能图标
@export var icon: Texture2D
## 效果容器
@export var effect_container: AbilityEffectNode
## 效果配置文件路径
@export_file("*.json") var effect_config_path: String

## 所属技能组件
var _ability_component: AbilityComponent
## 技能上下文
var _context : Dictionary

signal cast_finished

## 应用技能
func apply(ability_component: AbilityComponent, context: Dictionary) -> void:
	_ability_component = ability_component
	_context = context
	if not effect_config_path.is_empty():
		_load_effect_config()
	_apply(context)

## 移除技能
func remove() -> void:
	effect_container.revoke()
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
	if not effect_container: return false
	var result = await effect_container.execute(_context)
	if result == AbilityEffectNode.STATUS.SUCCESS:
		GASLogger.info("技能{0}执行成功".format([self]))
		cast_finished.emit()
		return true
	GASLogger.error("技能{0}执行失败".format([self]))
	return false

## 从配置加载效果节点树
func _load_effect_config() -> void:
	if effect_config_path.is_empty():
		return
	var effect_tree = EffectNodeFactory.create_from_json(effect_config_path)
	if effect_tree:
		effect_container = effect_tree
	else:
		GASLogger.error("Failed to load effect config from: %s" % effect_config_path)

func _to_string() -> String:
	return ability_name
