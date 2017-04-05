warrior_power = warrior_power or class({})
local spell = warrior_power

-- Gah, load these via KV loads?
spell.target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
spell.target_type = DOTA_UNIT_TARGET_ALL
spell.target_flag = DOTA_UNIT_TARGET_FLAG_NONE

function spell:OnAbilityPhaseStart()
    StartAnimation(self:GetCaster(), {
        duration = 1.15,
        activity = ACT_DOTA_VICTORY,
        -- translate = "iron",
        rate = 2.0
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

    local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 1.25)

    local targets = FindUnitsInRadius(
        target:GetTeamNumber(),
        caster:GetAbsOrigin(),
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

    -- TODO: Move particle into addon and remove the 3d distortion.
    -- Remove: earthshaker_echoslam_start_c_egset.vpcf
    local particle_name = 'particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_egset.vpcf'
    local particle = ParticleManager:CreateParticle(
        particle_name,
        PATTACH_ABSORIGIN,
        caster
    )
    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
    -- ParticleManager:SetParticleControl(particle, 1, Vector(300, 0, 0))
    --ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    -- EmitSoundOn('Creep_Good_Melee.PreAttack', caster)
    EmitSoundOn('Hero_EarthShaker.Totem.Attack', target)
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.AbilityBasicsWarrior(spell)
Wrappers.FocusTargetAbility(spell)
