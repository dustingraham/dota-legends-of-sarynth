--[[
Fight

Start:
 - Roar, begin attacking.

Fire:
 - After 5 seconds, trigger first fire.
 - After 15 seconds, trigger two fires.
 - After 30 seconds, trigger four fires.

Aggro:
 - Dumb attack hero until someone dies.

--]]
function AiDruidsBossLogic(ai)

    --ai.TRANSITION = 'ActionTransition'

    ai.ACTION_IDLE = 'ActionIdle'
    ai.ACTION_FIGHT_STANDARD = 'ActionFightStandard'
    ai.ACTION_RETURN = 'ActionReturn'

    function ai:StartFight()
        Debug('AiDarkBoss', 'Starting fight state.')
        EmitSoundOn('lone_druid_lone_druid_bearform_ability_battlecry_01', self:GetParent())

        self:FireOn()
        self:WallOn()

        -- TODO: Report all heroes in area.
        Encounter:Start(self:GetParent(), self.aggroTarget, self)

        self:TransitionTo(ai.ACTION_FIGHT_STANDARD)
        self:AttackTarget()
    end

    function ai:ActionFightStandard()
        -- Fight Starts, attack for 5 seconds.
        -- Check for unit closer than target if target is running away.
        if not self:ReviewTargets() then
            -- No targets found, we're done here.
            return true
        end

        --...?
    end

    function ai:TransitionToReturn()
        -- Remove aggro target.
        self.aggroTarget = nil

        self:FireIdle()
        self:WallOff()

        -- Remove all negative modifiers.
        self:ModPurge() -- Also removes activity modifiers!

        -- Another full health insurance.
        self:GetParent():SetHealth(self:GetParent():GetMaxHealth())

        local target = self:GetParent().spawn.spawnPoint
        self:GetParent():MoveToPosition( target ) --Move back to the spawnpoint
        self.returnTarget = target

        self:TransitionTo(ai.ACTION_RETURN)
    end

    -- In the process of returning.
    function ai:ActionReturn()
        --Check if the AI unit has reached its spawn location yet
        if (self.returnTarget - self:GetParent():GetAbsOrigin()):Length() < 10 then
            self:TransitionToIdle()
            return true
        end

        -- Keep attempting to move, in case we were stunned.
        self:GetParent():MoveToPosition(self.returnTarget) --Move back to the spawnpoint

        -- Sometimes we can't get there...
        if self.timeInState > 10 then
            self:Debug('Could not return in 10 ticks, safety idling.')
            self:TransitionToIdle()
            return true
        end
    end

    -- Made it back, transition to idle.
    function ai:TransitionToIdle()
        local pos = Entities:FindByName(nil, 'zone_druids_boss_center'):GetAbsOrigin()
        self:GetParent():FaceTowards(pos)

        --Go into the idle state
        self:TransitionTo(ai.ACTION_IDLE)

        -- Another full health insurance.
        self:GetParent():SetHealth(self:GetParent():GetMaxHealth())
    end

    function ai:ActionIdle()
        local units = self:FindHeroes(400)
        --If one or more units were found, start attacking the first one
        if #units > 0 then
            self.aggroTarget = units[1]
            self:StartFight()
            return true
        end
    end
end
