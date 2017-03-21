ranger_ice_arrow = ranger_ice_arrow or class({})
local spell = ranger_ice_arrow

-- Gah, load these via KV loads?
spell.target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
spell.target_type = DOTA_UNIT_TARGET_ALL
spell.target_flag = DOTA_UNIT_TARGET_FLAG_NONE

function spell:GetCastRange()
    return 800
end

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
    
    target:AddNewModifier(caster, self, 'ranger_slow', { duration = 9 })
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.FocusTargetAbility(spell)

LinkLuaModifier('ranger_slow', 'app/systems/characters/abilities/ranger/ranger_slow', LUA_MODIFIER_MOTION_NONE)
