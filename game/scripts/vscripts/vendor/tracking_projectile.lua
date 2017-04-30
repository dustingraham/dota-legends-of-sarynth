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
function TrackingProjectile( params )
    local target = params.Target
    local target_location = params.TargetPosition
    if target then
        target_location = target:GetAbsOrigin()
    end

    local caster = params.Caster
    local speed = params.iMoveSpeed

    --Set creation time in the parameters
    params.creation_time = GameRules:GetGameTime()

    --Fetch initial projectile location
    local projectile = caster:GetAttachmentOrigin( params.iSourceAttachment )

    --Make the particle
    local particle = ParticleManager:CreateParticle( params.EffectName, PATTACH_CUSTOMORIGIN, caster)
    --Source CP
    ParticleManager:SetParticleControl( particle, 0, caster:GetAttachmentOrigin( params.iSourceAttachment ) )
    ParticleManager:SetParticleControl( particle, 1, caster:GetAttachmentOrigin( params.iSourceAttachment ) )
    ParticleManager:SetParticleControl( particle, 3, caster:GetAttachmentOrigin( params.iSourceAttachment ) )
    ParticleManager:SetParticleControl( particle, 4, caster:GetAttachmentOrigin( params.iSourceAttachment ) )
    ParticleManager:SetParticleControl( particle, 9, caster:GetAttachmentOrigin( params.iSourceAttachment ) )
    --TargetCP
    if target then
        ParticleManager:SetParticleControlEnt( particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true )
    else
        -- ParticleManager:SetParticleControl( particle, 1, target_location )
    end

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
            OnProjectileHitUnit( params )

            --Stop the timer
            return nil
        else
            --Reschedule for next frame
            return 1/32
        end
    end)
end

--Called when the projectile hits the target, params contains the params of the projectile plus a creation_time field.
function OnProjectileHitUnit( params )
    params.Callback(params)
    print( params.Caster:GetUnitName() .. '\'s particle hit target after ' ..
    ( GameRules:GetGameTime() - params.creation_time ) .. ' seconds.' )
end
