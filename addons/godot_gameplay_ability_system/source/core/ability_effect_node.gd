extends Resource
class_name AbilityEffectNode

## 资源节点基类，通过Resource组成树状结构

## 节点状态
enum STATUS {
	SUCCESS,    ## 成功
	FAILURE,    ## 失败
}

## 是否启用
@export var enabled := true

## 节点状态
var state : STATUS = STATUS.SUCCESS	
## 节点是否已执行
var is_executed : bool = false

## 节点状态改变
signal state_changed(state: STATUS)

## 执行
func execute(context: Dictionary) -> STATUS:
	if not enabled: return STATUS.FAILURE
	# 如果已执行，则无法再次执行
	if is_executed: return STATUS.FAILURE
	return _execute(context)

## 撤销
func revoke() -> STATUS:
	if not enabled: return STATUS.FAILURE
	# 如果未执行，则无法撤销
	if not is_executed: return STATUS.FAILURE
	return _revoke()

## 子类中实现的执行方法
func _execute(context: Dictionary) -> STATUS:
	return STATUS.SUCCESS

## 子类中实现的撤销方法
func _revoke() -> STATUS:
	return STATUS.FAILURE
