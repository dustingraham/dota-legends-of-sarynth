ranger_strong_shot = ranger_strong_shot or class({})
local spell = ranger_strong_shot

function spell:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not IsValidEntity(target) then
        print('OSS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end

    local projectile_speed = 1300
    local particle_name = 'particles/units/heroes/ranger/strong_shot/ranger_strong_shot.vpcf'
    -- local particle_name = 'particles/units/heroes/hero_templar_assassin/templar_assassin_base_attack.vpcf'

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
    EmitSoundOn('Creep_Good_Melee.PreAttack', caster)
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
    EmitSoundOn('Hero_Zuus.Attack', caster)
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.AbilityBasicsRanger(spell)
Wrappers.FocusTargetAbility(spell)
