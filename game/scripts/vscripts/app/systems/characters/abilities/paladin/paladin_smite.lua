paladin_smite = paladin_smite or class({})
local spell = paladin_smite

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

    local projectile_speed = 1000
    local particle_name = 'particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot.vpcf'

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
    EmitSoundOn('Hero_SkywrathMage.ConcussiveShot.Cast', caster)
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
    EmitSoundOn('Hero_SkywrathMage.ConcussiveShot.Target', target)
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.AbilityBasicsPaladin(spell, 600)
Wrappers.FocusTargetAbility(spell)
