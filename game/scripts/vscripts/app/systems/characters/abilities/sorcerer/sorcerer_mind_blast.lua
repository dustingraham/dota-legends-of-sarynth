sorcerer_mind_blast = sorcerer_mind_blast or class({})
local spell = sorcerer_mind_blast

function spell:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not IsValidEntity(target) then
        print('OSS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end

    local projectile_speed = 1500
    local particle_name = 'particles/neutral_fx/satyr_trickster_projectile.vpcf'

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
    local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 0.75)

    -- Direct Deal
    ApplyDamage({
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL
    })

    EmitSoundOn('Hero_Terrorblade.Attack', target) -- todo
    target:AddNewModifier(caster, self, 'sorcerer_blasted', { duration = 2 })
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.AbilityBasicsSorcerer(spell)
Wrappers.FocusTargetAbility(spell)

LinkLuaModifier('sorcerer_blasted', 'app/systems/characters/abilities/sorcerer/sorcerer_mind_blast', LUA_MODIFIER_MOTION_NONE)

sorcerer_blasted = sorcerer_blasted or class({})
local mod = sorcerer_blasted

function mod:IsHidden()
    return false
end

function mod:IsDebuff()
    return true
end

function mod:IsStunDebuff()
    return true
end

function mod:GetEffectName()
    return "particles/generic_gameplay/generic_stunned.vpcf"
end

function mod:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function mod:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
    }
end

function mod:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
end

function mod:GetOverrideAnimation(params)
    return ACT_DOTA_DISABLED
end
