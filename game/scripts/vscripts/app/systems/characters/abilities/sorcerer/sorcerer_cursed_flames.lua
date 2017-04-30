sorcerer_cursed_flames = sorcerer_cursed_flames or class({})
local spell = sorcerer_cursed_flames

function spell:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not IsValidEntity(target) then
        print('OSS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end

    local projectile_speed = 900
    -- local particle_name = 'particles/econ/items/drow/drow_bow_monarch/drow_frost_arrow_monarch.vpcf'
    local particle_name = 'particles/units/heroes/sorcerer/sorcerer_cursed_flames.vpcf'

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
    EmitSoundOn('Hero_Phoenix.PreAttack', caster) -- todo
end

function spell:OnProjectileHit(target, pos)
    local caster = self:GetCaster()
    local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 1.05)

    ScreenShake(pos, 3, 100, 0.35, 2000, 0, true)

    -- Damage Deal
    ApplyDamage({
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL
    })

    local particle_name = 'particles/units/heroes/sorcerer/cursed_flames_impact/sorcerer_cursed_flames_impact.vpcf'
    local particle = ParticleManager:CreateParticle(
        particle_name,
        PATTACH_CUSTOMORIGIN,
        caster
    )
    ParticleManager:SetParticleControl( particle, 0, pos )
    ParticleManager:ReleaseParticleIndex(particle)

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
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL
        })
    end
    EmitSoundOn('Hero_Phoenix.IcarusDive.Stop', caster) -- todo
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.AbilityBasicsSorcerer(spell)
Wrappers.FocusTargetAbility(spell)
