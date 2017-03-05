ai_aggro_leash = ai_aggro_leash or class({})

function ai_aggro_leash:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        
        MODIFIER_EVENT_ON_ATTACK_ALLIED,
        
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
    }
end

-- ai_aggro_leash.STATE_IDLE = 0
-- ai_aggro_leash.STATE_AGGRO = 10
-- ai_aggro_leash.STATE_RETURN = 20
-- ai_aggro_leash.StateActions = [
--     [ai_aggro_leash.STATE_IDLE] = 'ActionIdle'
--     [ai_aggro_leash.STATE_AGGRO] = 'ActionAggro'
--     [ai_aggro_leash.STATE_RETURN] = 'ActionReturn'
-- ]

ai_aggro_leash.ACTION_IDLE = 'ActionIdle'
ai_aggro_leash.ACTION_AGGRO = 'ActionAggro'
ai_aggro_leash.ACTION_RETURN = 'ActionReturn'

if IsServer() then
    function ai_aggro_leash:OnCreated(keys)
        Debug('AiAggroLeash', 'OnCreated')
        self.state = ai_aggro_leash.ACTION_IDLE
        Debug('AiAggroLeash', 'Idling OC')
        self.aggroRange = self:GetParent().spawn.spawnNode.AggroRange or 400
        self.leashRange = self:GetParent().spawn.spawnNode.LeashRange or 750
        self:StartIntervalThink(1.0)
    end
end

function ai_aggro_leash:GetModifierHealthRegenPercentage()
    if self.state == ai_aggro_leash.ACTION_AGGRO then return 0.0 end
    return 20.0
end

function ai_aggro_leash:OnAttackAllied(event)
    Debug('AiAggroLeash', 'OnAttackAllied PRE')
    if self:GetParent() ~= event.target then return end
    Debug('AiAggroLeash', 'OnAttackAllied')
end

function ai_aggro_leash:OnTakeDamage(event)
    if self:GetParent() ~= event.unit then return end
    
    if self.state == ai_aggro_leash.ACTION_IDLE then
        self:GetParent():MoveToTargetToAttack( event.attacker ) --Start attacking
        self.aggroTarget = event.attacker
        self.state = ai_aggro_leash.ACTION_AGGRO --State transition
        Debug('AiAggroLeash', 'Aggroing')
    end
end

function ai_aggro_leash:OnDeath(event)
    if self:GetParent() ~= event.unit then return end
    Debug('AiAggroLeash', 'OnDeath')
    self:GetParent().spawn:OnDeath(self)
end

function ai_aggro_leash:OnIntervalThink()
    Dynamic_Wrap(ai_aggro_leash, self.state)(self)
end

function ai_aggro_leash:ActionIdle()
    local units = FindUnitsInRadius( self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil,
        self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
        FIND_ANY_ORDER, false )
    
    --If one or more units were found, start attacking the first one
    if #units > 0 then
        self:GetParent():MoveToTargetToAttack( units[1] ) --Start attacking
        self.aggroTarget = units[1]
        self.state = ai_aggro_leash.ACTION_AGGRO --State transition
        Debug('AiAggroLeash', 'Aggroing')
        return true
    end
    
    self:ActionIdleMove()
end
function ai_aggro_leash:ActionAggro()
    --Check if the unit has walked outside its leash range
    if ( self:GetParent().spawn.spawnPoint - self:GetParent():GetAbsOrigin() ):Length() > self.leashRange then
        self:TransitionToReturn()
        return true --Return to make sure no other code is executed in this state
    end

    --Check if the unit's target is still alive (self.aggroTarget will have to be set when transitioning into this state)
    if not self.aggroTarget:IsAlive() then
        self:TransitionToReturn()
        return true --Return to make sure no other code is executed in this state
    end

    --State behavior
    --Here we can just do any behaviour you want to repeat in this state
end

function ai_aggro_leash:TransitionToReturn()
    local target = self:GetParent().spawn.spawnPoint + Vector(math.random(-128, 128), math.random(-128, 128))
    self:GetParent():MoveToPosition( target ) --Move back to the spawnpoint
    self.returnTarget = target
    self.state = ai_aggro_leash.ACTION_RETURN --Transition the state to the 'Returning' state(!)
    self.returnTicks = 0
    Debug('AiAggroLeash', 'Returning')
end

function ai_aggro_leash:ActionReturn()
    --Check if the AI unit has reached its spawn location yet
    if ( self.returnTarget - self:GetParent():GetAbsOrigin() ):Length() < 10 then
        self:TransitionToIdle()
        return true
    end
    
    -- Sometimes we can't get there...
    self.returnTicks = self.returnTicks + 1
    if self.returnTicks > 10 then
        self:TransitionToIdle()
        return true
    end
end

function ai_aggro_leash:TransitionToIdle()
    --Go into the idle state
    self.state = ai_aggro_leash.ACTION_IDLE
    Debug('AiAggroLeash', 'Idling')
end

function ai_aggro_leash:ActionIdleMove()
    -- 10% chance to move.
    -- local rand = math.random(0, 10)
    -- if rand < 10 then return end
    if RollPercentage(80) then return end
    
    -- Move!
    local target = self:GetParent().spawn.spawnPoint + Vector(math.random(-196, 196), math.random(-196, 196))
    self:GetParent():MoveToPosition(target)
end
