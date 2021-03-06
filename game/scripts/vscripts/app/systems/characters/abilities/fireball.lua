fireball = fireball or class({})

local spell = fireball

-- Gah, load these via KV loads?
spell.target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
spell.target_type = DOTA_UNIT_TARGET_ALL
spell.target_flag = DOTA_UNIT_TARGET_FLAG_NONE

function spell:GetCastRange()
    return 1050
end

function spell:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    
    if not IsValidEntity(target) then
        print('OSS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end
    
    local projectile_speed = 500
    
    -- local particle_name = 'particles/econ/items/abaddon/abaddon_alliance/abaddon_death_coil_alliance.vpcf'
    -- local particle_name = 'particles/hw_fx/hw_rosh_fireball.vpcf'
    -- local particle_name = 'particles/ui/ui_lina_fireball.vpcf'
    -- local particle_name = 'particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_ambient.vpcf'
    -- local particle_name = 'particles/econ/items/drow/drow_bow_monarch/drow_frost_arrow_monarch.vpcf'
    
    -- Create the projectile
    ProjectileManager:CreateTrackingProjectile({
        Target = target,
        Source = caster,
        Ability = self,
        EffectName = 'particles/units/heroes/hero_lina/lina_base_attack.vpcf',
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
--    local d1 = caster:GetBaseDamageMin()
--    local d2 = caster:GetBaseDamageMax()
--    local d3 = caster:GetBonusDamageFromPrimaryStat()
--    local d4 = caster:GetPrimaryStatValue()
--    local d5 = caster:GetAttackDamage()
    
    --local total = caster:GetAverageTrueAttackDamage(target)
    -- local base = math.floor((caster:GetBaseDamageMin() + caster:GetBaseDamageMax()) / 2)
    -- local bonus = total - base
    --print(total, base, bonus)
    
    local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 4.25)
    
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
