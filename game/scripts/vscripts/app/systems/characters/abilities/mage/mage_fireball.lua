mage_fireball = mage_fireball or class({})
local spell = mage_fireball

function spell:OnAbilityPhaseStart()
    EmitSoundOn('Hero_Lina.PreAttack', self:GetCaster())
    return true
end

function spell:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not IsValidEntity(target) then
        print('OSS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end

    local projectile_speed = 1000
    local particle_name = 'particles/units/heroes/hero_lina/lina_base_attack.vpcf'

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
    EmitSoundOn('Hero_Lina.Attack', caster)
end

function spell:OnProjectileHit(target, pos)
    local caster = self:GetCaster()
    local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 2.25)

    -- Damage Deal
    ApplyDamage({
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL
    })
    EmitSoundOn('Hero_Lina.ProjectileImpact', caster)
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.AbilityBasicsMage(spell)
Wrappers.FocusTargetAbility(spell)
