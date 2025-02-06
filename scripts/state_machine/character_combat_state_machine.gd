extends BaseStateMachine
class_name CharacterCombatStateMachine

# region 状态定义
enum CombatState {
    IDLE,           # 待机
    PREPARE,        # 准备行动
    MOVING,         # 移动中
    CASTING,        # 施法中
    STUNNED,        # 被击晕
    DEAD,           # 死亡
    RETURNING       # 返回原位
}
# endregion

# region 变量定义
var combat_component: CombatComponent
# endregion

func _ready() -> void:
    add_state("idle", IdleState.new())
    add_state("prepare", PrepareState.new())
    add_state("moving", MovingState.new())
    add_state("casting", CastingState.new())
    add_state("stunned", StunnedState.new())
    add_state("dead", DeadState.new())
    add_state("returning", ReturningState.new())
    
    combat_component = agent.get_node("CombatComponent")

# region 基础战斗状态
class IdleState:
    extends BaseState
    
    func _enter(_msg: Dictionary = {}) -> void:
        var combat_comp := state_machine.combat_component
        combat_comp._is_actioning = false
        # 播放待机动画

class PrepareState:
    extends BaseState
    
    func _enter(_msg: Dictionary = {}) -> void:
        var combat_comp := state_machine.combat_component
        combat_comp._is_actioning = true
        # 准备行动，可能播放准备动画

class MovingState:
    extends BaseState
    
    func _enter(msg: Dictionary = {}) -> void:
        var combat_comp := state_machine.combat_component
        var target_pos = msg.get("target_position")
        if target_pos:
            # 移动到目标位置
            pass

class CastingState:
    extends BaseState
    
    func _enter(msg: Dictionary = {}) -> void:
        var combat_comp := state_machine.combat_component
        var ability = msg.get("ability")
        if ability:
            await combat_comp.ability_component.activate_ability(ability)
            state_machine.switch_to("returning")

class StunnedState:
    extends BaseState
    
    func _enter(msg: Dictionary = {}) -> void:
        var duration = msg.get("duration", 1.0)
        # 播放眩晕动画
        await get_tree().create_timer(duration).timeout
        state_machine.switch_to("idle")

class DeadState:
    extends BaseState
    
    func _enter(_msg: Dictionary = {}) -> void:
        var combat_comp := state_machine.combat_component
        combat_comp._is_actioning = false
        # 播放死亡动画

class ReturningState:
    extends BaseState
    
    func _enter(_msg: Dictionary = {}) -> void:
        var combat_comp := state_machine.combat_component
        # 返回原位
        await get_tree().create_timer(combat_comp.return_action_time).timeout
        state_machine.switch_to("idle")
# endregion