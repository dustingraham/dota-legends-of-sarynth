self_regen = self_regen or class({})
local spell = self_regen

function spell:OnAbilityPhaseStart()
    EmitSoundOn('Hero_Omniknight.GuardianAngel.Cast', self:GetCaster())
    return true
end
function spell:OnSpellStart()
    spell.mod = self:GetCaster():AddNewModifier(self:GetCaster(), self, 'self_regen_modifier', {})
    -- Sounds:EmitSoundOnClient(self:GetCaster():GetPlayerOwnerID(), 'Hero_Terrorblade.Attack')
    -- EmitSoundOnClient('Hero_Terrorblade.Attack', PlayerResource:GetPlayer(0))
    -- Does not appear to play
end

-- function spell:OnChannelThink(interval)
--print('thinking', interval)
--PopupPoison(self:GetCaster(), 25)
-- end

function spell:OnChannelFinish(interrupted)
    -- TODO: Stun if interrupted?
    spell.mod:Destroy()
end

LinkLuaModifier('self_regen_modifier', 'app/systems/characters/abilities/self_regen_modifier', LUA_MODIFIER_MOTION_NONE)
