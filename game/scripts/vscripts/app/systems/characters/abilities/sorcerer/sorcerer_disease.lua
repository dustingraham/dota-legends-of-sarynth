sorcerer_disease = sorcerer_disease or class({})
local spell = sorcerer_disease

function spell:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not IsValidEntity(target) then
        print('OSS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end

    local projectile_speed = 1000
    local particle_name = 'particles/units/heroes/sorcerer/disease/sorcerer_disease.vpcf'

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
    local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 0.40)

    -- Damage Deal
    --ApplyDamage({
    --    victim = target,
    --    attacker = caster,
    --    damage = damage,
    --    damage_type = DAMAGE_TYPE_MAGICAL
    --})
    target:AddNewModifier(caster, self, 'sorcerer_diseased', {
        duration = 15,
        damage = damage,
        interval = 1,
    })
    EmitSoundOn('Hero_Zuus.Attack', caster) -- todo
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.AbilityBasicsSorcerer(spell)
Wrappers.FocusTargetAbility(spell)

LinkLuaModifier('sorcerer_diseased', 'app/systems/characters/abilities/sorcerer/sorcerer_disease', LUA_MODIFIER_MOTION_NONE)

sorcerer_diseased = sorcerer_diseased or class({})
local mod = sorcerer_diseased

function mod:IsHidden()
    return false
end

function mod:IsDebuff()
    return true
end

function mod:OnCreated(params)
    if IsServer() then
        self.damage_per_tick = params.damage
        self:StartIntervalThink(params.interval)
    end
end

function mod:OnDestroy()
    -- ParticleManager:DestroyParticle(self.particle_flame, false)
end

function mod:OnIntervalThink()
    ApplyDamage({
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.damage_per_tick,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        -- damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
        ability = self:GetAbility(),
    })
    PopupDisease(self:GetParent(), self.damage_per_tick)
end
