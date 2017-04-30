rogue_stats = rogue_stats or class({})
local mod = rogue_stats

function mod:IsPassive()
    return true
end

function mod:IsPurgable()
    return false
end

function mod:RemoveOnDeath()
    return false
end

function mod:IsHidden()
    return true
end

function mod:GetModifierEvasion_Constant()
    return 30
end

function mod:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_EVASION_CONSTANT,
    }
end
