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

function mod:OnCreated()
    print('WarriorOnCreated')
end

function mod:IsHidden()
    return false
end

function mod:GetModifierConstantHealthRegen()
    return 1
end

function mod:GetModifierConstantManaRegen()
    return 0
end

function mod:GetModifierExtraHealthPercentage()
    -- Double base health (1 + n) * base
    return 1
end

function mod:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
    }
end
