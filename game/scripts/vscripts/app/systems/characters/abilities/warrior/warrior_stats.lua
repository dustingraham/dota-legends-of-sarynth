warrior_stats = warrior_stats or class({})
local mod = warrior_stats

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

function mod:GetModifierHealthRegenPercentage()
    return 0.5
end

function mod:GetModifierConstantManaRegen()
    return 0
end

function mod:GetModifierExtraHealthPercentage()
    -- Double base health (1 + n) * base
    return 0.5
end

function mod:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        --MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
    }
end
