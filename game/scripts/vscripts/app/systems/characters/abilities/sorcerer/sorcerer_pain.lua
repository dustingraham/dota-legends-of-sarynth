sorcerer_pain = sorcerer_pain or class({})
local spell = sorcerer_pain

-- Gah, load these via KV loads?
spell.target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
spell.target_type = DOTA_UNIT_TARGET_ALL
spell.target_flag = DOTA_UNIT_TARGET_FLAG_NONE

function spell:GetCastRange()
    return 1000
end

function spell:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    
    if not IsValidEntity(target) then
        print('OSS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end
    
    local projectile_speed = 700
    local particle_name = 'particles/econ/items/abaddon/abaddon_alliance/abaddon_death_coil_alliance.vpcf'
    
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
end

function spell:OnProjectileHit(target, pos)
    local caster = self:GetCaster()
    
    local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 2.25)
    
    -- TODO: DOT damage over time modifier
    
    -- Damage Deal
    ApplyDamage({
        victim = target,
        attacker = caster,
        damage = damage, 
        damage_type = DAMAGE_TYPE_MAGICAL
    })
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.FocusTargetAbility(spell)
