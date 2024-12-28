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

## 技能触发时机
enum TRIGGER_TYPE{
	NONE,
	CAST,			## 技能释放
	ATTACK,			## 攻击
	DEATH,			## 死亡
	TURN_START,		## 回合开始
	TURN_END,		## 回合结束
	COMBAT_START,	## 战斗开始
	COMBAT_END,		## 战斗结束
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