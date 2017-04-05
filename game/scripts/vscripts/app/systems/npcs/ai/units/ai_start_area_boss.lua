ai_start_area_boss = ai_start_area_boss or class({})
local ai = ai_start_area_boss

function ai:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_ATTACK_ALLIED,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
    }
end

-- Good claw impact
-- particles/units/heroes/hero_life_stealer/life_stealer_open_wounds_impact.vpcf

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

ai.ACTION_FIGHT_STANDARD = 'ActionFightStandard'

if IsServer() then
    function ai:OnCreated(keys)
        Debug('StartAreaBoss', 'OnCreated')
        self.state = ai.ACTION_IDLE
        Debug('StartAreaBoss', 'Idling OC')
        self.aggroRange = 850
        self.leashRange = 2000
        -- self.aggroRange = self:GetParent().spawn.spawnNode.AggroRange or 400
        -- self.leashRange = self:GetParent().spawn.spawnNode.LeashRange or 750
        self:StartIntervalThink(1.0)
    end
end

function ai:GetModifierHealthRegenPercentage()
    if self.state == ai.ACTION_RETURN then return 10.0 end
    if self.state == ai.ACTION_IDLE then return 20.0 end
    return 0.0
end

function ai:OnAttackAllied(event)
    Debug('StartAreaBoss', 'OnAttackAllied PRE')
    if self:GetParent() ~= event.target then return end
    Debug('StartAreaBoss', 'OnAttackAllied')
end

function ai:OnTakeDamage(event)
    if self:GetParent() ~= event.unit then return end

    if self.state == ai.ACTION_IDLE then
        Debug('StartAreaBoss', 'Aggroing due to Attacked')
        self.aggroTarget = event.attacker
        self:StartFight()
    end
end

function ai:OnDeath(event)
    if self:GetParent() ~= event.unit then return end
    Debug('StartAreaBoss', 'OnDeath')
    self:GetParent().spawn:OnDeath(self)

    Encounter:Log('Boss died, ending encounter.')
    Encounter:End()
    -- Takes a slight second for him to fall backwards.
    local pos = self:GetParent():GetAbsOrigin()
    Timers:CreateTimer(0.45, function()
        ScreenShake(pos, 10, 150, 2.5, 3000, 0, true)
    end)
end

function ai:OnIntervalThink()
    Dynamic_Wrap(ai, self.state)(self)
end

-- self:AbilityClawAttack()
function ai:AbilityClawAttack()
    StartAnimation(self:GetParent(), {
        duration = 0.5,
        activity = ACT_DOTA_ATTACK,
        rate = 1.5,
    })
    ParticleManager:ReleaseParticleIndex(ParticleManager:CreateParticle(
        'particles/units/start/scar/claw.vpcf',
        PATTACH_ABSORIGIN_FOLLOW,
        self:GetParent()
    ))

end

function ai:StartFight()
    Debug('StartAreaBoss', 'Starting fight state.')
    self.state = ai.ACTION_FIGHT_STANDARD
    Encounter:Start(self:GetParent(), self.aggroTarget)

    -- Howl and attack.
    EmitSoundOn('Hero_Lycan.Howl', self:GetParent())
    StartAnimation(self:GetParent(), {
        duration = 3.0,
        activity = ACT_DOTA_CAST_ABILITY_2,
        rate = 0.35,
    })
    Timers:CreateTimer(3.0, function()
        Debug('StartAreaBoss', 'Starting Attack')
        self:GetParent():MoveToTargetToAttack(self.aggroTarget)
    end)
end

function ai:ActionIdle()
    local units = FindUnitsInRadius(
        self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil,
        self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER, false
    )

    --If one or more units were found, start attacking the first one
    if #units > 0 then
        Debug('StartAreaBoss', 'Aggroing due to Range')
        self.aggroTarget = units[1]
        self:StartFight()
        return true
    end

    self:ActionIdleMove()
end

function ai:ChargeAttack()
    Timers:CreateTimer(8.0, function()
        self:GetParent():Stop()
        StartAnimation(self:GetParent(), {
            duration = 2.0,
            activity = ACT_DOTA_CAST_ABILITY_1,
        })
        EmitSoundOn('lycan_lycan_ability_howl_01', self:GetParent())
        Timers:CreateTimer(2.0, function()
            self:AbilityClawAttack()
        end)
    end)
end

function ai:UseAbility()
    -- Concept
    --self:GetParent():AddAbility('ranger_poison_arrow')
    --Timers:CreateTimer(5.0, function()
    --    local ability = self:GetParent():FindAbilityByName('ranger_poison_arrow')
    --    self:GetParent():CastAbilityOnTarget(units[1], ability, -1)
    --end)
end

--function ai:ActionAggro()
function ai:ActionFightStandard()
    --Check if the unit has walked outside its leash range
    if ( self:GetParent().spawn.spawnPoint - self:GetParent():GetAbsOrigin() ):Length() > self.leashRange then
        self:TransitionToReturn()
        return true --Return to make sure no other code is executed in this state
    end

    --Check if the unit's target is still alive (self.aggroTarget will have to be set when transitioning into this state)
    if not self.aggroTarget:IsAlive() then
        -- TODO Look for another target in the area!!
        self:TransitionToReturn()
        return true --Return to make sure no other code is executed in this state
    end

    --State behavior
    --Here we can just do any behaviour you want to repeat in this state
    if not self:GetParent():IsAttacking() then
        self:FallbackAttackCheck()
    end
end

-- If we get stuck somewhere, start attacking after 5 seconds.
function ai:FallbackAttackCheck()
    if self.fallbackCheck == nil then
        self.fallbackCheck = 0
    end
    self.fallbackCheck = self.fallbackCheck + 1
    if self.fallbackCheck > 5 then
        self:GetParent():MoveToTargetToAttack(self.aggroTarget)
        self.fallbackCheck = nil
    end
end

function ai:TransitionToReturn()
    -- Remove aggro target.
    self.aggroTarget = nil

    -- Remove all negative modifiers.
    for _,modifier in pairs(self:GetParent():FindAllModifiers()) do
        if modifier ~= self then
            -- Proper Reset?
            Debug('StartAreaBoss', 'Removing: '..modifier:GetName())
            modifier:Destroy()
        end
    end

    local target = self:GetParent().spawn.spawnPoint + Vector(math.random(-64, 64), math.random(-64, 64))
    self:GetParent():MoveToPosition( target ) --Move back to the spawnpoint
    self.returnTarget = target
    self.state = ai.ACTION_RETURN --Transition the state to the 'Returning' state(!)
    self.returnTicks = 0
    Debug('StartAreaBoss', 'Returning')
end

function ai:ActionReturn()
    --Check if the AI unit has reached its spawn location yet
    if ( self.returnTarget - self:GetParent():GetAbsOrigin() ):Length() < 10 then
        self:TransitionToIdle()
        return true
    end

    -- Sometimes we can't get there...
    if not self.returnTicks then
        self.returnTicks = 0
    end
    self.returnTicks = self.returnTicks + 1

    -- Keep attempting to move, in case we were stunned.
    self:GetParent():MoveToPosition( self.returnTarget ) --Move back to the spawnpoint

    if self.returnTicks > 10 then
        Debug('StartAreaBoss', 'Could not return in 10 ticks, safety idling.')
        self:TransitionToIdle()
        return true
    end
end

function ai:TransitionToIdle()
    --Go into the idle state
    self.state = ai.ACTION_IDLE
    self.returnTicks = nil
    Debug('StartAreaBoss', 'Idling')
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
