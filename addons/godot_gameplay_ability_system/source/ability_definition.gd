extends RefCounted
class_name AbilityDefinition

## 定义技能系统所需要的常量数据

## 属性修改器类型
enum ATTRIBUTE_MODIFIER_TYPE{
	NONE,
	VALUE,		## 修改值
	PERCENTAGE,	## 百分比
	ABSOLUTE		## 绝对值
}

## BUFF类型
enum BUFF_TYPE{
	NONE,
	DURATION,	## 持续型
	VALUE,		## 数值型
}

## 技能目标类型
enum TARGET_TYPE{
	NONE,
	SELF,		## 自己
	ENEMY,		## 敌人
	ALLY,		## 盟友
	ENEMY_ALL,	## 敌人全员
	ALLY_ALL,	## 盟友全员
	ALL,		## 所有
}

## 技能施法位置
enum CASTING_POSITION
{
	NONE, 			## 默认施法位置
	MELEE,			## 近战施法位置
	RANGED,			## 远程施法位置
	BEHINDENEMY,	## 身后施法位置
}
