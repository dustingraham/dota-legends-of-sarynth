ranger_concussive_shot = ranger_concussive_shot or class({})
local spell = ranger_concussive_shot

function spell:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not IsValidEntity(target) then
        print('OSS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end

    local projectile_speed = 1500
    local particle_name = 'particles/units/heroes/ranger/concussive_shot/ranger_concussive_shot.vpcf'

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
    local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 0.75)

    -- Damage Deal
    ApplyDamage({
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL
    })
    target:AddNewModifier(caster, self, 'ranger_concussion', { duration = 2 })
    EmitSoundOn('Hero_Terrorblade.Attack', target)
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.AbilityBasicsRanger(spell)
Wrappers.FocusTargetAbility(spell)

LinkLuaModifier('ranger_concussion', 'app/systems/characters/abilities/ranger/ranger_concussion', LUA_MODIFIER_MOTION_NONE)
