character_hidden = character_hidden or class({})

-- function modifier_hidden:IsHidden()
--     return true
-- end

function character_hidden:CheckState()
    return {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true, -- self:GetParent():GetUnitName() == "npc_dota_hero_wisp",
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_BLIND] = true
    }
end

function character_hidden:IsStunDebuff()
    return true
end
