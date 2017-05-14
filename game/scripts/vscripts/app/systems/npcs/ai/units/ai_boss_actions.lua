function AiBossActions(ai, zoneName, debugName)

    function ai:Debug(...)
        Debug(debugName, ...)
    end

    function ai:TransitionTo(toState)
        Debug(debugName, 'TransitionTo', toState)
        self.timeInState = 0
        self.state = toState
    end

    function ai:AttackTarget()
        self:GetParent():MoveToTargetToAttack(self.aggroTarget)
    end

    function ai:ReviewTargets()
        local currentPos = self:GetParent():GetAbsOrigin()
        local foundAnyTargets = false
        local closestRange
        local closestHero
        local furthestRange
        local furthestHero
        -- Find, closest target, and furthest target in range of bomb.
        -- Closest target
        for _,hero in pairs(self:FindHeroes(3000)) do
            if hero.currentZone == zoneName then
                if GridNav:CanFindPath(hero:GetAbsOrigin(), currentPos) then
                    local distance = (hero:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D()
                    if not foundAnyTargets then
                        foundAnyTargets = true
                        closestRange = distance
                        closestHero = hero
                        furthestRange = distance
                        furthestHero = hero
                    else
                        if distance < closestRange then
                            closestRange = distance
                            closestHero = hero
                        end
                        -- Furthest, but in range of bomb. (1500 range, check 1400 to be safe.)
                        if distance > furthestRange and distance < 1400 then
                            furthestRange = distance
                            furthestHero = hero
                        end
                    end
                end
            end
            --print(
            --    hero:GetUnitName(), hero.currentZone,
            --    'At', (hero:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D(),
            --    'Can', GridNav:CanFindPath(hero:GetAbsOrigin(), self:GetParent():GetAbsOrigin())
            --)
        end
        if foundAnyTargets then
            if self.aggroTarget ~= closestHero then
                Debug(debugName, 'Found closer target to aggro.')
                self.aggroTarget = closestHero
            end
            if self.rangedTarget ~= furthestHero then
                Debug(debugName, 'Found different ranged hero to target.')
                self.rangedTarget = furthestHero
            end
        else
            -- Initialize if needed.
            if not self.noTargetsFound then self.noTargetsFound = 0 end
            self.noTargetsFound = self.noTargetsFound + 1
            if self.noTargetsFound > 5 then
                Encounter:Log('No viable targets found for 5 ticks, ending encounter.')
                --self:OnEncounterEnd()
                Encounter:End()
            end
        end

        return foundAnyTargets
    end

    function ai:FindHeroes(range, sourcePosition)
        sourcePosition = sourcePosition or self:GetParent():GetAbsOrigin()
        return FindUnitsInRadius(
        self:GetParent():GetTeam(),
        sourcePosition,
        nil,
        range,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
        )
    end

    function ai:DealDamage(target, damage, damageType, source)
        if not source then source = self:GetParent() end
        if not damageType then damageType = DAMAGE_TYPE_MAGICAL end
        ApplyDamage({
                        victim = target,
                        attacker = source,
                        damage = damage,
                        damage_type = damageType
                    })
    end

    function ai:ModPurge()
        for _,modifier in pairs(self:GetParent():FindAllModifiers()) do
            if modifier ~= self then
                -- Proper Reset?
                Debug(debugName, 'ModPurge Removing: '..modifier:GetName())
                modifier:Destroy()
            end
        end
    end
end
