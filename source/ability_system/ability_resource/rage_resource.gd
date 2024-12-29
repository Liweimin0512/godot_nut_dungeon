extends AbilityResource
class_name RageResource

## 怒气类资源
## 受到伤害时 +5
## 造成伤害时 +10
## 扩展：击杀单位时 +20

## 造成伤害时恢复的值
@export var regain_hited: int = 10
## 受到伤害时恢复的值
@export var regain_hurted: int = 5

func initialization(ability_component: AbilityComponent) -> void:
	super(ability_component)
	current_value = 0
	ability_resource_name = "怒气值"

func on_hit(_context: Dictionary) -> void:
	restore(regain_hited)

func on_hurt(_context: Dictionary) -> void:
	restore(regain_hurted)
