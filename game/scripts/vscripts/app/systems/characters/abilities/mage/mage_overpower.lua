mage_overpower = mage_overpower or class({})
local spell = mage_overpower

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

    local particle_name = 'particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf'
    local particle = ParticleManager:CreateParticle(
        particle_name,
        PATTACH_ABSORIGIN,
        caster
    )
    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 2, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    caster:AddNewModifier(caster, self, 'mage_overpowered', { duration = 15 })

    EmitSoundOn('Hero_Invoker.Invoke', caster)
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

LinkLuaModifier('mage_overpowered', 'app/systems/characters/abilities/mage/mage_overpower', LUA_MODIFIER_MOTION_NONE)

--- Modifier
mage_overpowered = mage_overpowered or class({})
local mod = mage_overpowered

function mod:IsHidden()
    return false
end

function mod:IsBuff()
    return true
end
function mod:GetTexture()
    return 'custom/mage/mage_overpower'
end

function mod:OnCreated()
    if not IsServer() then return end
    mod.p1 = self:MakeParticle('attach_orb1')
    mod.p2 = self:MakeParticle('attach_orb2')
    mod.p3 = self:MakeParticle('attach_orb3')
end
function mod:MakeParticle(attach)
    local idx = ParticleManager:CreateParticle(
        'particles/econ/items/invoker/invoker_ti6/invoker_ti6_wex_orb.vpcf',
        PATTACH_OVERHEAD_FOLLOW, self:GetParent()
    )
    ParticleManager:SetParticleControlEnt(
        idx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, attach, self:GetParent():GetAbsOrigin(), true
    )
    ParticleManager:SetParticleControlEnt(
        idx, 2, self:GetParent(), PATTACH_POINT_FOLLOW, attach, self:GetParent():GetAbsOrigin(), true
    )
    return idx
end
function mod:OnDestroy()
    if not IsServer() then return end
    ParticleManager:DestroyParticle(mod.p1, false)
    ParticleManager:ReleaseParticleIndex(mod.p1)
    ParticleManager:DestroyParticle(mod.p2, false)
    ParticleManager:ReleaseParticleIndex(mod.p2)
    ParticleManager:DestroyParticle(mod.p3, false)
    ParticleManager:ReleaseParticleIndex(mod.p3)
end

function mod:CheckState()
    return {
        -- [MODIFIER_STATE_STUNNED] = true,
    }
end

function mod:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
    }
end

function mod:GetModifierAttackSpeedBonus_Constant()
    return 15.0
end

function mod:GetModifierMoveSpeedBonus_Percentage()
    return 10.0
end

function mod:GetModifierPercentageCooldown()
    return 60.0
end

-- Reduce mana costs by 50%
function mod:GetModifierPercentageManacost()
    return 50.0
end
