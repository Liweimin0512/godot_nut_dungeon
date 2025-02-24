extends RefCounted
class_name AIDecisionMaker


## 选择技能
func select_ability(abilities: Array[Ability]) -> Ability:
	return abilities[0]


## 选择目标
## [param abilities] 可选技能
## [param possible_targets] 可选目标
## [return] 选择的目标
func select_target(_ability: Ability, _possible_targets: Array) -> Node:
	return null
