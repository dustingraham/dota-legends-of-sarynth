character_passive_regen = character_passive_regen or class({})
local mod = character_passive_regen

function mod:GetIntrinsicModifierName()
    return "character_passive_regen"
end

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
        self.outOfCombatCooldown = 5
        self:StartIntervalThink(1/32)
    end
end

function mod:IsHidden()
    return self:GetStackCount() ~= 0
end

function mod:GetModifierConstantHealthRegen()
    if self:GetStackCount() ~= 0 then return 0 end
    return self.healthRegen
end

function mod:GetModifierConstantManaRegen()
    if self:GetStackCount() ~= 0 then return 0 end
    return self.manaRegen
end

function mod:GetTexture()
    return 'custom/self_regen'
end

function mod:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_EVENT_ON_ATTACKED,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_ABILITY_START,
    }
end

-- print(inspect(event, {depth = 1}))

function mod:OnAttack(event)
    if self:GetParent() ~= event.attacker then return end
    self.outOfCombatCooldown = 6
end
function mod:OnAttacked(event)
    if self:GetParent() ~= event.target then return end
    self.outOfCombatCooldown = 6
end
function mod:OnTakeDamage(event)
    if self:GetParent() ~= event.unit then return end
    self.outOfCombatCooldown = 6
end
function mod:OnAbilityStart(event)
    if self:GetParent() ~= event.unit then return end
    self.outOfCombatCooldown = 6
end

function mod:OnIntervalThink()
    if self.outOfCombatCooldown > 0 then
        self.outOfCombatCooldown = self.outOfCombatCooldown - 1/32
    end
    if self.outOfCombatCooldown < 0 then
        self.outOfCombatCooldown = 0
    end

    if self:GetParent():IsAlive() and self.outOfCombatCooldown == 0 then
        self.healthRegen = self:GetParent():GetMaxHealth() / 12
        self.manaRegen = self:GetParent():GetMaxMana() / 12
        self:SetStackCount(0)
    else
        self:SetStackCount(1)
    end
end
