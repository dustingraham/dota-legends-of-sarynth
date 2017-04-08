rogue_incapacitate = rogue_incapacitate or class({})
local spell = rogue_incapacitate

function spell:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not IsValidEntity(target) then
        print('OSS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end

    local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 0.75)

    -- Direct Deal
    ApplyDamage({
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_PHYSICAL
    })

    --local particle_name = 'particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail.vpcf'
    --local particle = ParticleManager:CreateParticle(
    --    particle_name,
    --    PATTACH_POINT,
    --    target
    --)
    --ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
    --ParticleManager:SetParticleControlEnt(particle, 2, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
    --ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin())
    --ParticleManager:SetParticleControl(particle, 4, target:GetAbsOrigin())
    --ParticleManager:ReleaseParticleIndex(particle)

    -- EmitSoundOn('Creep_Good_Melee.PreAttack', caster)
    EmitSoundOn('Hero_Terrorblade.Attack', target) -- todo
    target:AddNewModifier(caster, self, 'rogue_incapacitated', { duration = 2 })
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.AbilityBasicsRogue(spell)
Wrappers.FocusTargetAbility(spell)

LinkLuaModifier('rogue_incapacitated', 'app/systems/characters/abilities/rogue/rogue_incapacitate', LUA_MODIFIER_MOTION_NONE)

rogue_incapacitated = rogue_incapacitated or class({})
local mod = rogue_incapacitated

Wrappers.StunMod(mod)
