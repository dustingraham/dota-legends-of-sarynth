ranger_explosive_shot = ranger_explosive_shot or class({})
local spell = ranger_explosive_shot

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
    
    local projectile_speed = 1200
    -- local particle_name = 'particles/econ/items/drow/drow_bow_monarch/drow_frost_arrow_monarch.vpcf'
    local particle_name = 'particles/units/heroes/ranger/explosive_shot/ranger_explosive_shot.vpcf'
    
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
    local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 1.25)

    -- Damage Deal
    ApplyDamage({
        victim = target,
        attacker = caster,
        damage = damage, 
        damage_type = DAMAGE_TYPE_MAGICAL
    })
    
    local particle_name = 'particles/units/heroes/ranger/explosive_shot/ranger_explosive_shot_impact.vpcf'
    local particle = ParticleManager:CreateParticle(
        particle_name,
        PATTACH_CUSTOMORIGIN,
        caster
    )
    ParticleManager:SetParticleControl( particle, 0, pos )
    
    local targets = FindUnitsInRadius(
        target:GetTeamNumber(),
        pos,
        nil,
        250,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _,coTarget in pairs(targets) do
        ApplyDamage({
            victim = coTarget,
            attacker = caster,
            damage = damage*1000, 
            damage_type = DAMAGE_TYPE_MAGICAL
        })
    end        
    
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.FocusTargetAbility(spell)