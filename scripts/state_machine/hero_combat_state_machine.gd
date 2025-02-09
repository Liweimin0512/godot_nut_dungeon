extends CharacterCombatStateMachine
class_name HeroCombatStateMachine

func _ready() -> void:
    super._ready()
    # 添加英雄特有状态
    add_state("selecting_target", SelectingTargetState.new())
    add_state("selecting_ability", SelectingAbilityState.new())

# region 英雄特有状态
class SelectingTargetState:
    extends BaseState
    
    func _enter(msg: Dictionary = {}) -> void:
        var combat_comp := state_machine.combat_component
        var ability = msg.get("ability")
        # 显示目标选择UI
        # 等待玩家选择目标
        # 选择后切换到casting状态

class SelectingAbilityState:
    extends BaseState
    
    func _enter(_msg: Dictionary = {}) -> void:
        var combat_comp := state_machine.combat_component
        # 显示技能选择UI
        # 等待玩家选择技能
        # 选择后切换到selecting_target状态