extends CharacterCombatStateMachine
class_name EnemyCombatStateMachine

func _ready() -> void:
    super._ready()
    # 添加敌人特有状态
    add_state("deciding_action", DecidingActionState.new())

# region 敌人特有状态
class DecidingActionState:
    extends BaseState
    
    func _enter(_msg: Dictionary = {}) -> void:
        var combat_comp := state_machine.combat_component
        # AI决策逻辑
        var action = _decide_action()
        var target = _select_target()
        state_machine.switch_to("casting", {
            "ability": action,
            "target": target
        })
    
    func _decide_action() -> AbilityData:
        # AI选择行动的逻辑
        pass
    
    func _select_target() -> Node:
        # AI选择目标的逻辑
        pass
# endregion