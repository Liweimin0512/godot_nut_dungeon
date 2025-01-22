@tool
extends Node
class_name UIGroupComponent

## UI分组组件，代表父节点是一个UI分组
## 负责管理UI分组的生命周期和状态

## 分组名称
@export var group_name: StringName
## 默认过渡动画
@export var default_transition: UITransition
## 是否启用模态窗口
@export var enable_modal: bool = true

@export var ui_root : Node

func _enter_tree() -> void:
	if not ui_root: ui_root = get_parent()
	UIManager.set_group(group_name, self)

func _exit_tree() -> void:
	if UIManager.get_group(group_name) != self:
		push_error("Group %s is not a child of this component" % group_name)
		return
	UIManager.remove_group(group_name)
