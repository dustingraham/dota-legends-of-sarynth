-- GetActivityTranslationModifiers necessary for cm arcana + death?
ice_dungeon_boss3 = ice_dungeon_boss3 or class({})
local ai = ice_dungeon_boss3

function ai:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,

        MODIFIER_EVENT_ON_ATTACK_ALLIED,

        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,

        -- For the staff
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
    }
end

function ai:GetActivityTranslationModifiers()
    return "arcana"
end

-- ai.STATE_IDLE = 0
-- ai.STATE_AGGRO = 10
-- ai.STATE_RETURN = 20
-- ai.StateActions = [
--     [ai.STATE_IDLE] = 'ActionIdle'
--     [ai.STATE_AGGRO] = 'ActionAggro'
--     [ai.STATE_RETURN] = 'ActionReturn'
-- ]

ai.ACTION_IDLE = 'ActionIdle'
ai.ACTION_AGGRO = 'ActionAggro'
ai.ACTION_RETURN = 'ActionReturn'

if IsServer() then
    function ai:OnCreated(keys)
        Debug('AiAggroLeash', 'OnCreated')
        self.state = ai.ACTION_IDLE
        Debug('AiAggroLeash', 'Idling OC')
        self.aggroRange = self:GetParent().spawn.spawnNode.AggroRange or 400
        self.leashRange = self:GetParent().spawn.spawnNode.LeashRange or 750
        self:StartIntervalThink(1.0)

        --local idx = ParticleManager:CreateParticle(
        --    'particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_arcana_body_ambient.vpcf',
        --    PATTACH_POINT_FOLLOW,
        --    self:GetParent()
        --)
        --ParticleManager:ReleaseParticleIndex(idx)
    end
end

function ai:GetModifierHealthRegenPercentage()
    if self.state == ai.ACTION_AGGRO then return 0.0 end
    return 20.0
end

function ai:OnAttackAllied(event)
    Debug('AiAggroLeash', 'OnAttackAllied PRE')
    if self:GetParent() ~= event.target then return end
    Debug('AiAggroLeash', 'OnAttackAllied')
end

function ai:OnTakeDamage(event)
    if self:GetParent() ~= event.unit then return end

    print('TakeDamage')

    if self.state == ai.ACTION_IDLE then
        self:GetParent():MoveToTargetToAttack( event.attacker ) --Start attacking
        self.aggroTarget = event.attacker
        self.state = ai.ACTION_AGGRO --State transition
        Debug('AiAggroLeash', 'Aggroing')
    end
end
function ai:OnDeath(event)
    if self:GetParent() ~= event.unit then return end
    Debug('AiAggroLeash', 'OnDeath')
    local idx = ParticleManager:CreateParticle(
        'particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_death_arcana.vpcf',
        PATTACH_POINT_FOLLOW, -- PATTACH_ABSORIGIN_FOLLOW, -- PATTACH_OVERHEAD_FOLLOW,
        self:GetParent()
    )
    ParticleManager:ReleaseParticleIndex(idx)
    self:GetParent().spawn:OnDeath(self)
end

function ai:OnIntervalThink()
    Dynamic_Wrap(ai, self.state)(self)
end

function ai:ActionIdle()
    local units = FindUnitsInRadius( self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil,
                                     self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE,
                                     FIND_ANY_ORDER, false )

    --If one or more units were found, start attacking the first one
    if #units > 0 then
        self:GetParent():MoveToTargetToAttack( units[1] ) --Start attacking
        self.aggroTarget = units[1]
        self.state = ai.ACTION_AGGRO --State transition
        Debug('AiAggroLeash', 'Aggroing')
        return true
    end

    self:ActionIdleMove()
end
function ai:ActionAggro()
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

function ai:TransitionToReturn()
    local target = self:GetParent().spawn.spawnPoint + Vector(math.random(-128, 128), math.random(-128, 128))
    self:GetParent():MoveToPosition( target ) --Move back to the spawnpoint
    self.returnTarget = target
    self.state = ai.ACTION_RETURN --Transition the state to the 'Returning' state(!)
    self.returnTicks = 0
    Debug('AiAggroLeash', 'Returning')
end

function ai:ActionReturn()
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

function ai:TransitionToIdle()
    --Go into the idle state
    self.state = ai.ACTION_IDLE
    Debug('AiAggroLeash', 'Idling')
end

function ai:ActionIdleMove()
    -- 10% chance to move.
    -- local rand = math.random(0, 10)
    -- if rand < 10 then return end
    if RollPercentage(80) then return end

    -- Move!
    local target = self:GetParent().spawn.spawnPoint + Vector(math.random(-196, 196), math.random(-196, 196))
    self:GetParent():MoveToPosition(target)
end
