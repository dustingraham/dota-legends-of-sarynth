paladin_divine_blow = paladin_divine_blow or class({})
local spell = paladin_divine_blow

function spell:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not IsValidEntity(target) then
        print('OSS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end

    local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 0.65)

    ApplyDamage({
        victim = target,
        attacker = caster,
        damage = damage * 2,
        damage_type = DAMAGE_TYPE_PHYSICAL
    })
    DoCleaveAttack(caster, target, self, damage, 200, 140, 600, 'particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf')

    local particle = ParticleManager:CreateParticle(
        'particles/econ/events/ti5/dagon_lvl2_ti5.vpcf',
        PATTACH_POINT,
        caster
    )
    local position = target:GetAbsOrigin() + (caster:GetAbsOrigin() - target:GetAbsOrigin()) / 2
    ParticleManager:SetParticleControl(particle, 0, position)
    ParticleManager:SetParticleControl(particle, 1, position)
    ParticleManager:ReleaseParticleIndex(particle)

    EmitSoundOn('Hero_EarthShaker.Totem', target)
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.AbilityBasicsPaladin(spell)
Wrappers.FocusTargetAbility(spell)
