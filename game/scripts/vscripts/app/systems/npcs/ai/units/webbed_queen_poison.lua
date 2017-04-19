webbed_queen_poison = webbed_queen_poison or class({})
local spell = webbed_queen_poison

function spell:OnSpellStart()
    print('Spell Start')
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not IsValidEntity(target) then
        print('OSS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end

    local projectile_speed = 1000
    local particle_name = 'particles/econ/items/abaddon/abaddon_alliance/abaddon_death_coil_alliance.vpcf'

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
    EmitSoundOn('Creep_Good_Melee.PreAttack', caster) -- todo
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
    EmitSoundOn('Hero_Zuus.Attack', caster) -- todo
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.AbilityBasicsSorcerer(spell)
--Wrappers.FocusTargetAbility(spell)
