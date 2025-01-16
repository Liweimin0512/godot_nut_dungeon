extends Resource
class_name UIType

## UI控件数据模型，根据这个模型实例化控件对应的UI场景

@export var ID : StringName = ""
@export var scene : PackedScene = null
@export var groupID : StringName = ""
@export var hide_others : bool = true						## 是否隐藏其他界面

func _init(ID: StringName = "", scene:PackedScene = null, groupID: StringName = "", hide_others: bool = true) -> void:
	self.ID = ID
	self.scene = scene
	self.groupID = groupID
	self.hide_others = hide_others
