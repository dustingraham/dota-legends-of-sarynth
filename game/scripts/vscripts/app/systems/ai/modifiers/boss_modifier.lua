boss_modifier = boss_modifier or class({})
local mod = boss_modifier

function mod:IsDebuff() return false end
function mod:IsHidden() return true end

function mod:DeclareFunctions()
    return {
        -- MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        -- MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
        -- MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        -- MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
end

-- TODO: Zone Check?


function mod:OnTakeDamage(event)
    if self:GetParent() ~= event.unit then
        return
    end

    local ai = self:GetParent().ai
    if ai and ai:IsIdle() then
        ai:Debug('Aggroing due to Attacked')
        ai:StartFight(event.attacker)
    end
end

function mod:GetModifierConstantHealthRegen()
    local ai = self:GetParent().ai
    return ai and ai:GetHealthRegen() or 0
end
