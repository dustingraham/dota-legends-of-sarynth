sorcerer_stats = sorcerer_stats or class({})
local mod = sorcerer_stats

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

function mod:GetModifierConstantHealthRegen()
    return 1
end

function mod:GetModifierConstantManaRegen()
    return 2
end

function mod:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
end
