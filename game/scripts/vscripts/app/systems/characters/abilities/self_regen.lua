self_regen = self_regen or class({})
local spell = self_regen

function spell:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET +
    DOTA_ABILITY_BEHAVIOR_CHANNELLED +
    -- These seem ignored...
    DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK +
    DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT
end

function spell:OnAbilityPhaseStart()
    EmitSoundOn('Hero_Omniknight.GuardianAngel.Cast', self:GetCaster())
    return true
end

function spell:OnSpellStart()
    spell.mod = self:GetCaster():AddNewModifier(self:GetCaster(), self, 'self_regen_modifier', {})
end

-- function spell:OnChannelThink(interval)
-- end

function spell:OnChannelFinish(interrupted)
    spell.mod:Destroy()
end

LinkLuaModifier('self_regen_modifier', 'app/systems/characters/abilities/self_regen_modifier', LUA_MODIFIER_MOTION_NONE)
