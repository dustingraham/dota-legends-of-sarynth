mage_ice_shock = mage_ice_shock or class({})
local spell = mage_ice_shock

function spell:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not IsValidEntity(target) then
        print('OSS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end

    local projectile_speed = 1100
    local particle_name = 'particles/units/heroes/hero_crystalmaiden/maiden_base_attack.vpcf'

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
    EmitSoundOn('hero_Crystal.attack', caster)
end

function spell:OnProjectileHit(target, pos)
    local caster = self:GetCaster()
    local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 0.65)

    -- Damage Deal
    ApplyDamage({
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL
    })
    EmitSoundOn('hero_Crystal.projectileImpact', caster)

    target:AddNewModifier(caster, self, 'mage_ice_shocked', { duration = 4 })
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.AbilityBasicsMage(spell)
Wrappers.FocusTargetAbility(spell)

LinkLuaModifier('mage_ice_shocked', 'app/systems/characters/abilities/mage/mage_ice_shock', LUA_MODIFIER_MOTION_NONE)

mage_ice_shocked = mage_ice_shocked or class({})
local mod = mage_ice_shocked

Wrappers.StunMod(mod)
