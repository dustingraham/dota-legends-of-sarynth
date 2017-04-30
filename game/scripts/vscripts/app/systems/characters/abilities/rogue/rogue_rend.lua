rogue_rend = rogue_rend or class({})
local spell = rogue_rend

function spell:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not IsValidEntity(target) then
        print('OSS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end

    local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 0.80)

    ApplyDamage({
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_PHYSICAL
    })

    local particle_name = 'particles/units/heroes/rogue/rend/rogue_rend.vpcf'
    local particle = ParticleManager:CreateParticle(
        particle_name,
        PATTACH_POINT,
        caster
    )
    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    target:AddNewModifier(caster, self, 'rogue_rend_bleeding', {
        duration = 18,
        damage = damage,
        interval = 1,
    })

    -- EmitSoundOn('Creep_Good_Melee.PreAttack', caster)
    EmitSoundOn('Hero_Terrorblade.Attack', target)
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.AbilityBasicsRogue(spell)
Wrappers.FocusTargetAbility(spell)

LinkLuaModifier('rogue_rend_bleeding', 'app/systems/characters/abilities/rogue/rogue_rend', LUA_MODIFIER_MOTION_NONE)

rogue_rend_bleeding = rogue_rend_bleeding or class({})
local mod = rogue_rend_bleeding

function mod:IsHidden()
    return false
end
function mod:IsDebuff()
    return true
end
function mod:GetTexture()
    return "custom/rogue/rogue_rend"
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
    PopupBleed(self:GetParent(), self.damage_per_tick)
end
