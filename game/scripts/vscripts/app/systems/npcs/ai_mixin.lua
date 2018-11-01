print('Loading global')

function AiMixin(ai)
    print('Executing AI Mixin....')

    -- Hurray for Arhowk
    function ai:GetAngle(unit, target)
        local sourceAngle = unit:GetForwardVector()
        local targetAngle = (target:GetAbsOrigin() - unit:GetAbsOrigin()):Normalized()

        sourceAngle       = math.atan2(sourceAngle.y, sourceAngle.x) * 180 / math.pi
        targetAngle       = math.atan2(targetAngle.y, targetAngle.x) * 180 / math.pi

        local angle       = targetAngle - sourceAngle + 180
        angle             = (angle - math.floor(angle /360) * 360)- 180

        -- Round, to ignore <1 degree.
        return math.floor((math.floor(angle *2) + 1)/2)
    end

    function ai:AnimatedFace(target, callback)
        local unit             = self:GetParent()
        local angle            = self:GetAngle(unit, target)
        local finalAngle       = (target:GetAbsOrigin() - unit:GetAbsOrigin()):Normalized()
        local currentDirection = unit:GetForwardVector()
        local radiansPerTick   = 0.18
        local radians          = angle * math.pi / 180
        print('Need to turn...')
        if angle ~= 0 then
            StartAnimation(self:GetParent(), {
                duration = 5,
                activity = ACT_DOTA_RUN,
                rate     = 1.0,
            })

            local currentAngle = math.atan2(currentDirection.y, currentDirection.x)
            local turned       = 0
            local turnLeft     = angle < 0
            local absRadians   = math.abs(radians)

            Timers(0.1, function()
                if self:IsNull() then
                    return
                end
                turned = turned + radiansPerTick
                if turned < absRadians then
                    if turnLeft then
                        currentAngle = currentAngle - radiansPerTick
                    else
                        currentAngle = currentAngle + radiansPerTick
                    end
                    self:GetParent():SetForwardVector(Vector(math.cos(currentAngle), math.sin(currentAngle), currentDirection.z))
                    return 0.03
                end

                -- Finally make sure it is perfect
                --self:GetParent():SetForwardVector(finalAngle)

                Timers(0.1, function()
                    print('happily turned?')
                    EndAnimation(self:GetParent())
                    callback()
                end)
            end)
        end
    end

    function ai:FindHeroes(range)
        return FindUnitsInRadius(
            self:GetParent():GetTeam(),
            self:GetParent():GetAbsOrigin(),
            nil,
            range,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )
    end
end
