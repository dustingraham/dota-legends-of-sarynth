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
        self.i = 0
        self.healthRegen = self:GetParent():GetMaxHealth() / 4
        self.manaRegen = self:GetParent():GetMaxMana() / 4
    end
end

function mod:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_EVENT_ON_ATTACKED,
    }
end

function mod:OnAttacked()
    print('Interrupting...')
    self:GetParent():InterruptChannel()
end

function mod:GetModifierConstantHealthRegen()
    return self.healthRegen
end

function mod:GetModifierConstantManaRegen()
    return self.manaRegen
end

function mod:OnIntervalThink()
    self.i = self.i + 1
    if self.i % 2 == 0 then
        PopupHealing(self:GetParent(), math.floor(self:GetParent():GetMaxHealth() / 8))
    else
        PopupManaing(self:GetParent(), math.floor(self:GetParent():GetMaxMana() / 8))
    end
end
