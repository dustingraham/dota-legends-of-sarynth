rogue_crippling_slash = rogue_crippling_slash or class({})
local spell = rogue_crippling_slash

function spell:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not IsValidEntity(target) then
        print('OSS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end

    local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 2.25)

    ApplyDamage({
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_PHYSICAL
    })
    PopupCriticalDamage(target, damage)

    local particle_name = 'particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinda_slow.vpcf'
    local particle = ParticleManager:CreateParticle(
        particle_name,
        PATTACH_POINT,
        caster
    )
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    -- EmitSoundOn('Creep_Good_Melee.PreAttack', caster)
    EmitSoundOn('Hero_Terrorblade.Attack', target)
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.AbilityBasicsRogue(spell)
Wrappers.FocusTargetAbility(spell)
