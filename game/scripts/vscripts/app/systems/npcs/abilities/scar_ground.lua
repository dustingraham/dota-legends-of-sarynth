scar_ground = scar_ground or class({})
local spell = scar_ground

function spell:OnAbilityPhaseStart()
    StartAnimation(self:GetCaster(), {
        duration = 1.5,
        activity = ACT_DOTA_ATTACK,
        rate = 0.4
    })
    return true
end

function spell:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not IsValidEntity(target) then
        print('OSS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end

    local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 0.85)

    local targets = FindUnitsInRadius(
    target:GetTeamNumber(), caster:GetAbsOrigin(),
    nil, 300,
    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _,coTarget in pairs(targets) do
        ApplyDamage({
                        victim = coTarget,
                        attacker = caster,
                        damage = damage,
                        damage_type = DAMAGE_TYPE_MAGICAL
                    })
        coTarget:AddNewModifier(caster, self, 'kobold_boss_slammed', { duration = 2 })
    end

    local particle = ParticleManager:CreateParticle(
    'particles/units/heroes/hero_ursa/ursa_earthshock.vpcf',
    PATTACH_ABSORIGIN,
    caster
    )
    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    -- EmitSoundOn('Creep_Good_Melee.PreAttack', caster)
    EmitSoundOn('Hero_EarthShaker.Totem.Attack', target)
end

function spell:GetCastRange()
    return 150
end
function spell:GetMaxLevel()
    return 1
end
function spell:GetBehavior()
    -- consider DOTA_ABILITY_BEHAVIOR_NO_TARGET
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

LinkLuaModifier('kobold_boss_slammed', 'app/systems/npcs/abilities/kobold_boss_slam', LUA_MODIFIER_MOTION_NONE)

kobold_boss_slammed = kobold_boss_slammed or class({})
local mod = kobold_boss_slammed

function mod:GetTexture()
    return "custom/warrior/warrior_ground_smash"
end

Wrappers.StunMod(mod)
