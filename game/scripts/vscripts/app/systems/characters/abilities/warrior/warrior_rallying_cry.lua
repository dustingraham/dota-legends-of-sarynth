warrior_rallying_cry = warrior_rallying_cry or class({})
local spell = warrior_rallying_cry

-- Gah, load these via KV loads?
spell.target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
spell.target_type = DOTA_UNIT_TARGET_ALL
spell.target_flag = DOTA_UNIT_TARGET_FLAG_NONE

--function spell:OnAbilityPhaseStart()
--    StartAnimation(self:GetCaster(), {
--        duration = 1.15,
--        activity = ACT_DOTA_VICTORY,
--        -- translate = "iron",
--        rate = 2.0
--    })
--    return true
--end

function spell:OnSpellStart()
    local caster = self:GetCaster()

    local particle_name = 'particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf'
    local particle = ParticleManager:CreateParticle(
        particle_name,
        PATTACH_ABSORIGIN,
        caster
    )
    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 2, caster:GetAbsOrigin())

    --- TODO NEEDS A PARTICLE SETTTTT

    -- ParticleManager:SetParticleControl(particle, 1, Vector(300, 0, 0))
    --ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)


    caster:AddNewModifier(caster, self, 'warrior_rallied_boost', { duration = 15 })

    -- EmitSoundOn('Creep_Good_Melee.PreAttack', caster)
    EmitSoundOn('Hero_EarthShaker.Totem.Attack', caster)
end
function spell:GetMaxLevel()
    return 1
end
function spell:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

--if IsClient() then
--    require('app/systems/characters/abilities/wrappers')
--end

LinkLuaModifier('warrior_rallied_boost', 'app/systems/characters/abilities/warrior/warrior_rallying_cry', LUA_MODIFIER_MOTION_NONE)

--- Modifier
warrior_rallied_boost = warrior_rallied_boost or class({})
local mod = warrior_rallied_boost

function mod:IsHidden()
    return false
end

function mod:IsBuff()
    return true
end
function mod:GetTexture()
    return "custom/warrior/warrior_rallying_cry"
end
function mod:GetStatusEffectName()
    return "particles/status_fx/status_effect_doom.vpcf"
end
function mod:GetHeroEffectName()
    return "particles/econ/items/dragon_knight/dk_aurora_warrior/dk_aurora_warrior_weapon_ambient.vpcf"
end
function mod:GetEffectName()
    return "particles/econ/items/dragon_knight/dk_aurora_warrior/dk_aurora_warrior_shield_ambient.vpcf"
end
function mod:CheckState()
    return {
        -- [MODIFIER_STATE_STUNNED] = true,
    }
end

function mod:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
    }
end

function mod:GetModifierAttackSpeedBonus_Constant()
    return 20.0
end

function mod:GetModifierMoveSpeedBonus_Percentage()
    return 20.0
end

function mod:GetModifierPercentageCooldown()
    return 80.0
end
