archer_ice_arrow = archer_ice_arrow or class({})
local spell = archer_ice_arrow

function spell:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not IsValidEntity(target) then
        print('OSS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end

    local projectile_speed = 900
    local particle_name = 'particles/units/heroes/ranger/ice_arrow/ranger_ice_arrow.vpcf'

    -- Create the projectile
    ProjectileManager:CreateTrackingProjectile({
       Target = target,
       Source = caster,
       Ability = self,
       EffectName = particle_name,
       bDodgeable = false,
       bProvidesVision = true,
       iMoveSpeed = projectile_speed,
       iVisionRadius = 0,
       iVisionTeamNumber = caster:GetTeamNumber(),
       iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
    })
    EmitSoundOn('hero_Crystal.preAttack', caster)
end

function spell:OnProjectileHit(target, pos)
    local caster = self:GetCaster()

    local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 0.75)

    -- Damage Deal
    ApplyDamage({
        victim = target,
    attacker = caster,
    damage = damage,
    damage_type = DAMAGE_TYPE_MAGICAL
    })

    target:AddNewModifier(caster, self, 'ice_arrow_slow', { duration = 6 })
    EmitSoundOn('hero_Crystal.projectileImpact', target)
end

function spell:GetCastRange()
    return 800
end
function spell:GetMaxLevel()
    return 1
end
function spell:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

LinkLuaModifier('ice_arrow_slow', 'app/systems/npcs/abilities/archer_ice_arrow', LUA_MODIFIER_MOTION_NONE)

ice_arrow_slow = ice_arrow_slow or class({})
local mod = ice_arrow_slow

function mod:IsHidden()
    return false
end

function mod:IsDebuff()
    return true
end

function mod:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost.vpcf"
end
function mod:GetTexture()
    return "custom/ranger/ranger_ice_arrow"
end
function mod:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function mod:GetModifierMoveSpeedBonus_Percentage()
    return -40
end
