self_regen_modifier = self_regen_modifier or class({})
local mod = self_regen_modifier

function mod:IsHidden()
    return true
end

function mod:IsDebuff()
    return false
end

function mod:OnCreated(params)
    -- local target = self:GetParent()
    if IsServer() then
        self:StartIntervalThink(0.25)
    end
end


function mod:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
    }
end
function mod:GetModifierHealthRegenPercentage()
    return 10
end

function mod:OnIntervalThink()
    PopupHealing(self:GetParent(), math.floor(self:GetParent():GetMaxHealth() / 40))
end
