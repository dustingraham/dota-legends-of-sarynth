warrior_great_cleave = warrior_great_cleave or class({})
local spell = warrior_great_cleave

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

    local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 1.05)

    ApplyDamage({
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_PHYSICAL
    })
    DoCleaveAttack(caster, target, self, damage, 200, 140, 600, 'particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf')

    local particle_name = 'particles/units/heroes/hero_chaos_knight/chaos_knight_weapon_blur_critical.vpcf'
    local particle = ParticleManager:CreateParticle(
    particle_name,
    PATTACH_POINT,
    caster
    )
    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    -- EmitSoundOn('Creep_Good_Melee.PreAttack', caster)
    EmitSoundOn('Hero_Terrorblade.Attack', target)
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.AbilityBasicsWarrior(spell)
Wrappers.FocusTargetAbility(spell)
