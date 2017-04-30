dark_fireball = dark_fireball or class({})
local spell = dark_fireball

function spell:OnAbilityPhaseStart()
    StartAnimation(self:GetCaster(), {
        duration = 5.0,
        activity = ACT_DOTA_ATTACK,
        rate = 0.65
    })
    --EmitSoundOn('Hero_Lycan.SummonWolves', self:GetCaster())


    --self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin()+Vector(0,0,60))
    return true
end

function spell:OnAbilityPhaseInterrupted()
    EndAnimation(self:GetCaster())
    --self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin()-Vector(0,0,60))
end

--------------------- TODO Projectile... -------------------
-- https://github.com/SteamDatabase/GameTracking-Dota2/blob/master/game/dota_addons/lua_ability_example/scripts/vscripts/lina_dragon_slave_lua.lua
-- Tracking Projectile

function spell:OnSpellStart()
    local caster = self:GetCaster()
    Timers(0.45, function()
        if IsValidEntity(caster) and caster:IsAlive() then
            EndAnimation(caster)
        end
    end)
    local position = self:GetCursorPosition()
    local indicatorParticle = ParticleManager:CreateParticle('particles/effects/ground_indicator.vpcf', PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(indicatorParticle, 0, position)
    ParticleManager:SetParticleControl(indicatorParticle, 1, Vector(315,0,0))

    local distance = (position - self:GetCaster():GetAbsOrigin()):Length2D()
    local speed = distance / 3
    --print(distance, speed)
    --print(DOTA_PROJECTILE_ATTACHMENT_ATTACK_1)
    local params = {
        Spell = self,
        TargetPosition = position,
        Caster = self:GetCaster(),
        iMoveSpeed = speed,
        indicatorParticle = indicatorParticle,
        -- iSourceAttachment = 'attach_hitloc',
        iSourceAttachment = 1,--DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
        EffectName = 'particles/hw_fx/hw_rosh_fireball.vpcf',
        Callback = function(params)
            if params.indicatorParticle then
                ParticleManager:DestroyParticle(params.indicatorParticle, false)
                ParticleManager:ReleaseParticleIndex(params.indicatorParticle)
                params.indicatorParticle = nil
            end
            local idx = ParticleManager:CreateParticle(
            'particles/econ/items/brewmaster/brewmaster_offhand_elixir/brewmaster_thunder_clap_elixir.vpcf',
            PATTACH_ABSORIGIN,
            params.Caster
            )
            ParticleManager:SetParticleControl(idx, 0, params.TargetPosition)
            ParticleManager:ReleaseParticleIndex(idx)


            local targets = FindUnitsInRadius(
            params.Caster:GetTeamNumber(),
            params.TargetPosition,
            nil,
            315,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
            for _,target in pairs(targets) do
                ApplyDamage({
                    victim = target,
                    attacker = params.Caster,
                    damage = 7500,
                    damage_type = DAMAGE_TYPE_MAGICAL
                })
            end

        end,
    }
    DarkFireballCopyOfTrackingProjectile(params)

    -- Ground Visual

    --local scarParticle = ParticleManager:CreateParticle('particles/units/start/scar/dark_fireball/dark_fireball.vpcf', PATTACH_CUSTOMORIGIN, self:GetCaster())
    --ParticleManager:SetParticleControl( scarParticle, 0, position )

    -- ParticleManager:SetParticleControl( scarParticle, 1, self:GetCaster():GetForwardVector() )

    -- Damaged Ground
    --Timers:CreateTimer(1.25, function()
    --    ticks = ticks + 1
    --    if not self:GetCaster():IsNull() and self:GetCaster():IsAlive() and Encounter.InEncounter then
    --        -- Make the ouch
    --        local units = FindUnitsInRadius(
    --        DOTA_TEAM_GOODGUYS,
    --        position,
    --        nil,
    --        150,
    --        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
    --        DOTA_UNIT_TARGET_ALL,
    --        DOTA_UNIT_TARGET_FLAG_NONE,
    --        FIND_ANY_ORDER,
    --        false
    --        )
    --        for _,ouchUnit in pairs(units) do
    --            ouchUnit:AddNewModifier(self:GetCaster(), self, 'dark_fireball_pain', { duration = 3 })
    --        end
    --        return 1
    --    else
    --        -- Stop the particle...
    --        ParticleManager:DestroyParticle(scarParticle, false)
    --        ParticleManager:ReleaseParticleIndex(scarParticle)
    --
    --        -- Delay to destroy the entity, otherwise particle clips off.
    --        --Timers(3, function()
    --        --    -- TODO: Create a single global dummy entity.
    --        --    entity:ForceKill(false)
    --        --end)
    --    end
    --end)

    -- EmitSoundOn('Hero_EarthShaker.Totem.Attack', target)
end

function spell:GetCastRange()
    return 1250
end
function spell:GetMaxLevel()
    return 1
end


--[[
    Lua tracking projectile.

	Author: Perry

    Requires a param with AT LEAST:
    - Target = the unit handle the projectile should fly to.
    - Caster = the unit handle the projectile originates from.
    - iMoveSpeed = the speed of the projectile
    - iSourceAttachment = the attachment the projectile originates from
    - EffectName = the path to the particle ('somethingsomething.vpcf')
]]
function DarkFireballCopyOfTrackingProjectile( params )
    local target_location = params.TargetPosition
    local caster = params.Caster
    local speed = params.iMoveSpeed

    --Set creation time in the parameters
    params.creation_time = GameRules:GetGameTime()

    --Fetch initial projectile location
    local projectile = caster:GetAttachmentOrigin( params.iSourceAttachment )
    projectile = projectile + caster:GetForwardVector() * 155
    print(projectile)
    --Make the particle
    local particle = ParticleManager:CreateParticle( params.EffectName, PATTACH_CUSTOMORIGIN, caster)

    --Source CP
    ParticleManager:SetParticleControl( particle, 0, projectile )
    ParticleManager:SetParticleControl( particle, 1, projectile )
    ParticleManager:SetParticleControl( particle, 3, projectile )
    ParticleManager:SetParticleControl( particle, 4, projectile )
    ParticleManager:SetParticleControl( particle, 9, projectile )

    --Speed CP
    ParticleManager:SetParticleControl( particle, 2, Vector( speed, 0, 0 ) )

    Timers:CreateTimer(function()
        --Get the target location
        if target then
            target_location = target:GetAbsOrigin()
        end

        --Move the projectile towards the target
        projectile = projectile + ( target_location - projectile ):Normalized() * speed * 1/32
        ParticleManager:SetParticleControl( particle, 0, projectile )
        ParticleManager:SetParticleControl( particle, 1, projectile )

        --Check the distance to the target
        if ( target_location - projectile ):Length2D() < speed * 1/32 then

            --Destroy particle
            ParticleManager:DestroyParticle( particle, false )
            --Release particle index
            ParticleManager:ReleaseParticleIndex( particle )

            --Target has reached destination!
            params.Callback(params)
            print( params.Caster:GetUnitName() .. '\'s particle hit target after ' ..
            ( GameRules:GetGameTime() - params.creation_time ) .. ' seconds.' )

            --Stop the timer
            return nil
        else
            --Reschedule for next frame
            return 1/32
        end
    end)
end
