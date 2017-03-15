ranger_slow = ranger_slow or class({})
local mod = ranger_slow

function mod:IsHidden()
    return false
end

function mod:IsDebuff()
    return true
end

function mod:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost.vpcf"
end

function mod:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function mod:GetModifierMoveSpeedBonus_Percentage()
    return -50
end
