mage_rupture_earth = mage_rupture_earth or class({})
local spell = mage_rupture_earth

function spell:OnAbilityPhaseStart()
    StartAnimation(self:GetCaster(), {
        duration = 0.7,
        activity = ACT_DOTA_CAST_ABILITY_2,
        translate = "iron",
        rate = 0.5
    })
    return true
end

function spell:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not IsValidEntity(target) then
        print('OSS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end

    local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 0.85)

    local targets = FindUnitsInRadius(
        target:GetTeamNumber(),
        target:GetAbsOrigin(),
        nil,
        300,
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

    local particle_name = 'particles/units/heroes/hero_ursa/ursa_earthshock.vpcf'
    local particle = ParticleManager:CreateParticle(
        particle_name,
        PATTACH_ABSORIGIN,
        caster
    )
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    EmitSoundOn('Hero_EarthShaker.Totem.Attack', target)
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.AbilityBasicsMage(spell)
Wrappers.FocusTargetAbility(spell)
