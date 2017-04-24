character_testmode = character_testmode or class({})
local mod = character_testmode

function mod:IsPassive()
    return true
end

function mod:IsPurgable()
    return false
end

function mod:RemoveOnDeath()
    return false
end

function mod:OnCreated()
    if IsServer() then
        self:StartIntervalThink(1/32)
    end
end

function mod:GetTexture()
    return 'custom/testmode'
end

function mod:IsHidden()
    return false
end

function mod:OnIntervalThink()
    local caster = self:GetParent()
end

function mod:GetModifierMoveSpeed_Max(params)
    if TEST_SUPERPATHEY then
        return TEST_SUPERPATHEY
    end
    return 550 -- Traditional dota default.
end

function mod:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_MAX,
    }
end
