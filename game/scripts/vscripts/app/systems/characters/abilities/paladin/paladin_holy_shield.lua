paladin_holy_shield = paladin_holy_shield or class({})
local spell = paladin_holy_shield

--function spell:OnAbilityPhaseStart()
--    StartAnimation(self:GetCaster(), {
--        duration = 1.15,
--        activity = ACT_DOTA_VICTORY,
--        -- translate = "iron",
--        rate = 2.0
--    })
--    return true
--end

function spell:OnSpellStart()
    local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, 'paladin_holy_shielded', { duration = 6 })
    EmitSoundOn('Hero_Omniknight.Purification', caster)
end
function spell:GetMaxLevel()
    return 1
end
function spell:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

--if IsClient() then
--    require('app/systems/characters/abilities/wrappers')
--end

LinkLuaModifier('paladin_holy_shielded', 'app/systems/characters/abilities/paladin/paladin_holy_shield', LUA_MODIFIER_MOTION_NONE)

--- Modifier
paladin_holy_shielded = paladin_holy_shielded or class({})
local mod = paladin_holy_shielded

function mod:IsHidden()
    return false
end

function mod:IsBuff()
    return true
end
function mod:GetTexture()
    return 'custom/paladin/paladin_holy_shield'
end
function mod:GetEffectName()
    return "particles/units/heroes/paladin/shield/paladin_holy_shield.vpcf"
end
function mod:CheckState()
    return {
        -- [MODIFIER_STATE_STUNNED] = true,
    }
end

function mod:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
    }
end

-- Reduce incoming damage by 75%.
function mod:GetModifierIncomingDamage_Percentage()
    return -75.0
end
-- Add 2% bonus regen.
function mod:GetModifierHealthRegenPercentage()
    return 2.0
end
