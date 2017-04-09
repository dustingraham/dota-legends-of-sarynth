paladin_blessing = paladin_blessing or class({})
local spell = paladin_blessing

function spell:OnSpellStart()
    local caster = self:GetCaster()

    local particle = ParticleManager:CreateParticle(
        'particles/units/heroes/paladin/blessing/paladin_blessing.vpcf',
        PATTACH_ABSORIGIN,
        caster
    )
    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 4, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    caster:AddNewModifier(caster, self, 'paladin_blessed', { duration = 15 })

    EmitSoundOn('Hero_Omniknight.GuardianAngel.Cast', caster)
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

LinkLuaModifier('paladin_blessed', 'app/systems/characters/abilities/paladin/paladin_blessing', LUA_MODIFIER_MOTION_NONE)

--- Modifier
paladin_blessed = paladin_blessed or class({})
local mod = paladin_blessed

function mod:IsHidden()
    return false
end

function mod:IsBuff()
    return true
end
function mod:GetTexture()
    return 'custom/paladin/paladin_blessing'
end

function mod:OnCreated()
    if not IsServer() then return end

    mod.stupidEntity = SpawnEntityFromTableSynchronous("prop_dynamic", {
        model = 'models/items/omniknight/omniknight_sacred_light_head/omniknight_sacred_light_head.vmdl'
    })
    mod.stupidEntity:FollowEntity(self:GetParent(), true)

    mod.particle = ParticleManager:CreateParticle(
        'particles/econ/items/omniknight/omni_sacred_light_head/omni_ambient_sacred_light.vpcf',
        PATTACH_CUSTOMORIGIN, mod.stupidEntity
    )
    ParticleManager:SetParticleControl(mod.particle, 0, mod.stupidEntity:GetAbsOrigin())
    ParticleManager:SetParticleControl(mod.particle, 6, mod.stupidEntity:GetAbsOrigin())
    ParticleManager:SetParticleControlEnt(
        mod.particle, 1, mod.stupidEntity, PATTACH_POINT_FOLLOW, 'attach_gem', mod.stupidEntity:GetAbsOrigin(), true
    )
    ParticleManager:SetParticleControlEnt(
        mod.particle, 2, mod.stupidEntity, PATTACH_POINT_FOLLOW, 'attach_halo', mod.stupidEntity:GetAbsOrigin(), true
    )
end

function mod:OnDestroy()
    if not IsServer() then return end

    ParticleManager:DestroyParticle(mod.particle, true)
    ParticleManager:ReleaseParticleIndex(mod.particle)
    mod.stupidEntity:Destroy()
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
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
    }
end

function mod:GetModifierAttackSpeedBonus_Constant()
    return 30.0
end

function mod:GetModifierMoveSpeedBonus_Percentage()
    return 10.0
end

function mod:GetModifierPercentageCooldown()
    return 40.0
end
