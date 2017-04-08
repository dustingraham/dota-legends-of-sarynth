warrior_sharp_jab = warrior_sharp_jab or class({})
local spell = warrior_sharp_jab

function spell:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not IsValidEntity(target) then
        print('OSS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end

    local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 1.25)

    ApplyDamage({
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_PHYSICAL
    })

    local particle_name = 'particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_slash_tgt_bonus.vpcf'
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

Wrappers.AbilityBasicsWarrior(spell)
Wrappers.FocusTargetAbility(spell)
