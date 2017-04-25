rogue_flurry = rogue_flurry or class({})
local spell = rogue_flurry

function spell:OnAbilityPhaseStart()
    StartAnimation(self:GetCaster(), {
        duration = 1.4,
        activity = ACT_DOTA_VICTORY,
        -- translate = "iron",
        rate = 1.0
    })
    return true
end

function spell:OnSpellStart()
    local caster = self:GetCaster()

    local particle_name = 'particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_cast.vpcf'
    local particle = ParticleManager:CreateParticle(
        particle_name,
        PATTACH_ABSORIGIN,
        caster
    )
    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 2, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 4, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    caster:AddNewModifier(caster, self, 'rogue_flurried', { duration = 18 })

    -- EmitSoundOn('Creep_Good_Melee.PreAttack', caster)
    EmitSoundOn('Hero_EarthShaker.Totem.Attack', caster)
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

LinkLuaModifier('rogue_flurried', 'app/systems/characters/abilities/rogue/rogue_flurry', LUA_MODIFIER_MOTION_NONE)

--- Modifier
rogue_flurried = rogue_flurried or class({})
local mod = rogue_flurried

function mod:IsHidden()
    return false
end

function mod:IsBuff()
    return true
end
function mod:GetTexture()
    return "custom/rogue/rogue_flurry"
end
function mod:GetStatusEffectName()
    return "particles/status_fx/status_effect_doom.vpcf"
end
function mod:OnCreated()
    self.p1 = self:WeaponParticle(
        'particles/units/heroes/hero_bounty_hunter/bounty_hunter_hand_l.vpcf',
        'attach_weapon2'
    )
    self.p2 = self:WeaponParticle(
        'particles/units/heroes/hero_bounty_hunter/bounty_hunter_hand_r.vpcf',
        'attach_weapon1'
    )
end
function mod:OnDestroy()
    ParticleManager:DestroyParticle(self.p1, true)
    ParticleManager:ReleaseParticleIndex(self.p1)
    ParticleManager:DestroyParticle(self.p2, true)
    ParticleManager:ReleaseParticleIndex(self.p2)
end
function mod:WeaponParticle(name, attachPosition)
    local idx = ParticleManager:CreateParticle(name, PATTACH_CUSTOMORIGIN, self:GetParent())
    ParticleManager:SetParticleControlEnt(
        idx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, attachPosition, self:GetParent():GetAbsOrigin(), true
    )
    return idx
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
    return 60.0
end

function mod:GetModifierMoveSpeedBonus_Percentage()
    return 30.0
end

function mod:GetModifierPercentageCooldown()
    return 40.0
end
