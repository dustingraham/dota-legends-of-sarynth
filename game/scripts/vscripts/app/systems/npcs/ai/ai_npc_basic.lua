ai_npc_basic = ai_npc_basic or class({})

function ai_npc_basic:CheckState()
    return {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true
    }
end

function ai_npc_basic:DeclareFunctions()
end

function ai_npc_basic:IsHidden()
    return true
end
