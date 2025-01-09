extends Resource
class_name AbilityEffectNode

## 资源节点基类，通过Resource组成树状结构

## 节点状态
enum STATUS {
	SUCCESS,    ## 成功
	FAILURE,    ## 失败
}

## 节点名称（ID), 用于获取节点
@export var effect_name: StringName = ""

## 是否启用
@export var enabled := true

## 节点状态
var state : STATUS = STATUS.SUCCESS	
## 节点是否已执行
var is_executed : bool = false
var _script_name: StringName = "":
	get:
		return get_script().resource_path.get_file().get_basename()

## 节点状态改变
signal state_changed(state: STATUS)

func _init():
	resource_local_to_scene = true

## 获取节点, 子类实现
func get_node(effect_name: StringName) -> AbilityEffectNode:
	return _get_effect_node(effect_name)
## 执行
func execute(context: Dictionary) -> STATUS:
	if not enabled: return STATUS.FAILURE
	# 如果已执行，则无法再次执行
	if is_executed: return STATUS.FAILURE
	return await _execute(context)

## 撤销
func revoke() -> STATUS:
	if not enabled: return STATUS.FAILURE
	# 如果未执行，则无法撤销
	if not is_executed: return STATUS.FAILURE
	return await _revoke()

## 子类中实现的执行方法
func _execute(context: Dictionary) -> STATUS:
	return STATUS.SUCCESS

## 子类中实现的撤销方法
func _revoke() -> STATUS:
	return STATUS.FAILURE

func _get_effect_node(effect_name: StringName) -> AbilityEffectNode:
	if effect_name == "":
		return self
	return get_node(effect_name)

func _get_context_value(context: Dictionary, key: StringName) -> Variant:
	if context.has(key):
		return context[key]
	GASLogger.error("AbilityEffectNode {0}: _get_context_value: context not has key: {1}".format([_script_name, key]))
	return null

func _to_string() -> String:
	if effect_name == "":
		return _script_name
	return "{0} : {1}".format([_script_name, effect_name])
