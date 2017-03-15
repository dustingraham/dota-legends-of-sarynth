ranger_concussion = ranger_concussion or class({})
local mod = ranger_concussion

function mod:IsHidden()
    return false
end

function mod:IsDebuff()
    return true
end

function mod:IsStunDebuff()
    return true
end

function mod:GetEffectName()
    return "particles/generic_gameplay/generic_stunned.vpcf"
end

function mod:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function mod:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
    }
end

function mod:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
end

function mod:GetOverrideAnimation(params)
    return ACT_DOTA_DISABLED
end