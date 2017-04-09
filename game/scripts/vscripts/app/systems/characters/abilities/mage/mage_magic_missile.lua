mage_magic_missile = mage_magic_missile or class({})
local spell = mage_magic_missile

function spell:OnAbilityPhaseStart()
    EmitSoundOn('Hero_Enigma.preAttack', self:GetCaster())
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
    local particle_name = 'particles/econ/items/enigma/enigma_geodesic/enigma_base_attack_eidolon_geodesic.vpcf'

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
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
    })
    EmitSoundOn('Hero_Enigma.Attack', caster)
end

function spell:OnProjectileHit(target, pos)
    local caster = self:GetCaster()
    local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 1.75)

    -- Damage Deal
    ApplyDamage({
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL
    })
    EmitSoundOn('Hero_Enigma.projectileImpact', caster)
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.AbilityBasicsMage(spell)
Wrappers.FocusTargetAbility(spell)
