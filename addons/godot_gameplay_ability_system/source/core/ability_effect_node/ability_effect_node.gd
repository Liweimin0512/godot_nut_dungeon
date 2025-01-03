extends Resource
class_name AbilityEffectNode

## 技能效果节点基类（技能效果将以树状结构存在）

## 节点状态
enum STATUS {
    SUCCESS,    ## 成功
    FAILURE,    ## 失败
    RUNNING,    ## 运行中
}

## 是否启用
@export var enabled := true

## 节点状态
var state : STATUS = STATUS.SUCCESS

## 节点状态改变
signal state_changed(state: STATUS)

## 执行
func execute(context: Dictionary) -> STATUS:
    if not enabled: return STATUS.FAILURE
    return _execute(context)

## 执行
func _execute(context: Dictionary) -> STATUS:
    return STATUS.SUCCESS
