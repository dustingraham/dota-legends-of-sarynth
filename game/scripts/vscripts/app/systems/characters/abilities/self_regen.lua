self_regen = self_regen or class({})
local spell = self_regen

function spell:OnSpellStart()
    spell.mod = self:GetCaster():AddNewModifier(self:GetCaster(), self, 'self_regen_modifier', {})
end

-- function spell:OnChannelThink(interval)
    --print('thinking', interval)
    --PopupPoison(self:GetCaster(), 25)
-- end

function spell:OnChannelFinish(interrupted)
    spell.mod:Destroy()
end

LinkLuaModifier('self_regen_modifier', 'app/systems/characters/abilities/self_regen_modifier', LUA_MODIFIER_MOTION_NONE)
