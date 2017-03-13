fireball = fireball or class({})

local spell = fireball

-- Gah, load these via KV loads?
spell.target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
spell.target_type = DOTA_UNIT_TARGET_ALL
spell.target_flag = DOTA_UNIT_TARGET_FLAG_NONE

function spell:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    
    if not IsValidEntity(target) then
        print('OSS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end
    
    local damage = 25
    
    -- Damage Deal
    -- TODO: Move damage into "hit"
    ApplyDamage({
        victim = target,
        attacker = caster,
        damage = damage, 
        damage_type = DAMAGE_TYPE_MAGICAL
    })
    
    local damage = 3150
    local amount = damage
    local projectile_speed = 1500
    
    -- local particle_name = 'particles/econ/items/abaddon/abaddon_alliance/abaddon_death_coil_alliance.vpcf'
    local particle_name = 'particles/hw_fx/hw_rosh_fireball.vpcf'
    
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

function spell:OnProjectileHit(hTarget, vLocation)
    print('[spell] OnProjectileHit')
    -- Explode!
end

function spell:GetCastRange()
    return 750
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.FocusTargetAbility(spell)
