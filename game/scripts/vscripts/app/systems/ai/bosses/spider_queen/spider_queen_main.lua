SpiderQueen = SpiderQueen or class({}, {
    name = 'SpiderQueen'
}, AiBase)
local ai = SpiderQueen
AiSystem:Register(ai)

--[[

Spider Queen
------------
At 0 seconds and every 60 seconds.
- Summons two wolf spiders.

Regular Attacks
Spits Triplicate Poison (Random 6 - 15 seconds)
If enemy 300 - 2000 distance detected: fires single poison splash. (Random 10-20 seconds.)

At 30 seconds, then every 60 seconds.
- Stops attacking, then does large AOE poison cloud that fades quickly.



Later Upgrade
-------------
Change to one wolf spider summon, and plants 6 spider eggs.
Spider eggs slowly get larger over 15 seconds, then hatch a wolf spider.

Periodically shell changes to full red, and starts attacking faster, harder, and with life steal.

]] --
ai.ACTION_IDLE = 'ActionIdle'
ai.ACTION_ATTACK = 'ActionAttack'
ai.ACTION_SUMMON = 'ActionSummon'
ai.ACTION_BLOOM = 'ActionBloom'
ai.ACTION_RETURN = 'ActionReturn'

function ai:constructor(entity)
    getbase(ai).constructor(self, entity)

    -- DebugDrawCircle(self:GetEntity():GetAbsOrigin(), Vector(255,0,0), 200, 2000, true, 20)

    self.state = ai.ACTION_IDLE
    self.isBusy = false
    self.aggroRange = 400
    self.leashRange = 2000
    self.timeInState = 0
    self.timeSinceSummon = 0
    self.timeSinceBloom = 30
    self.spiders = {}

    self.startLocation = self:GetEntity():GetAbsOrigin()
    self.passiveHealthRegen = Clamp(self:GetEntity():GetMaxHealth() / 10, 0, 800)

    self:Debug('Initialized')

    entity.isBoss = true
    entity:AddNewModifier(entity, nil, 'boss_modifier', nil)
end

------------
-- Logic
--
function ai:StartFight(attacker)
    self:Debug('Starting fight state.')
    if attacker then
        self.aggroTarget = attacker
    end
    Encounter:Start(self:GetEntity(), self.aggroTarget, self)

    self:TransitionTo(ai.ACTION_SUMMON)

    -- Howl and attack.
    --EmitSoundOn('Hero_Lycan.Howl', self:GetEntity())
end

function ai:ActionSummon()
    self:SummonWolfSpider()
    self:TransitionTo(ai.ACTION_ATTACK)
end

function ai:MakeLine(params)
    local length = params.length
    local width = params.width
    local duration = params.duration
    local targetPoint = params.targetPoint

    local sPart = 'particles/targeting/thick_line.vpcf'
    local idx = ParticleManager:CreateParticle(sPart, PATTACH_ABSORIGIN_FOLLOW, self:GetEntity())

    -- Should clamp to max distance of particle
    local diff = targetPoint - self:GetEntity():GetAbsOrigin()
    local toPoint = self:GetEntity():GetAbsOrigin() + diff:Normalized() * length
    ParticleManager:SetParticleControl(idx, 1, toPoint)

    -- Width
    ParticleManager:SetParticleControl(idx, 2, Vector(width, 0, 0))
    Timers(duration, function()
        ParticleManager:DestroyParticle(idx, false)
        ParticleManager:ReleaseParticleIndex(idx)
    end)
end

function ai:ActionAttack()
    local pSpawn = self:GetEntity().spawn.spawnPoint
    local pTarget = self.aggroTarget:GetAbsOrigin()
    local pBoss = self:GetEntity():GetAbsOrigin()
    local distance = max((pSpawn - pBoss):Length(), (pSpawn - pTarget):Length())
    -- Check if hero or boss are outside leash range
    if  distance > self.leashRange then
        if Encounter.InEncounter and Encounter.ai == self then
            self:Debug('Out of leash range... returning.')
            -- Do not review targets in this case.
            Encounter:Log('Out of leash range... returning.')
            Encounter:End()
        else
            self:Debug('Weird... should always be in an encounter??')
            self:TransitionToReturn()
        end
        return
    end

    self:AttackTarget()

    -- Check desire to fire triplicate.
    self:CheckTriplicateAttack()

    -- TODO: Check desire to fire single at ranged.

    -- At 30 seconds, then each 60 seconds.
    if self.timeSinceBloom > 60 then
        self:TransitionTo(ai.ACTION_BLOOM)
        return
    end

    -- At 0 seconds, then each 60 seconds.
    if self.timeSinceSummon > 60 then
        self:TransitionTo(ai.ACTION_SUMMON)
        return
    end
end

function ai:CheckTriplicateAttack()
    if self.timeInState % 8 == 2 then
        self:FireTriplicate()
    end
end

function ai:ActionSummon()
    self:SummonWolfSpider()
    self:TransitionTo(ai.ACTION_ATTACK)
end

function ai:ActionBloom()
    self:ExecutePoisonBloom()
    self:TransitionTo(ai.ACTION_ATTACK)
end

function ai:ActionIdle()
    --If one or more units are found in aggro range, start attacking the first one
    local units = self:FindHeroes(self.aggroRange)
    if #units > 0 then
        self:Debug('Aggroing due to Range')
        -- self.rangedTarget = units[1]
        self:StartFight(units[1])
        return true
    end

    -- Not interested in moving.
    -- self:ActionIdleMove()
end

function ai:ActionReturn()
    --Check if the AI unit has reached its spawn location yet
    if (self.returnTarget - self:GetEntity():GetAbsOrigin()):Length() < 10 then
        self:TransitionToIdle()
        return true
    end

    -- Sometimes we can't get there...
    if not self.returnTicks then
        self.returnTicks = 0
    end
    self.returnTicks = self.returnTicks + 1

    -- Keep attempting to move, in case we were stunned.
    self:GetEntity():MoveToPosition(self.returnTarget) --Move back to the spawnpoint

    if self.returnTicks > 10 then
        self:Debug('Could not return in 10 ticks, safety idling.')
        self:TransitionToIdle()
        return true
    end
end

------------
-- Actions
--
function ai:FaceTarget()
    self:AnimatedFace(self.aggroTarget, function()
        Timers(0.25, function()
            self:Debug('Facing Target!')
            -- Start attack.
            self:GetEntity():MoveToTargetToAttack(self.aggroTarget)
        end)
    end)
end

function ai:AttackTarget()
    self:GetEntity():MoveToTargetToAttack(self.aggroTarget)
end

function ai:TransitionTo(state)
    self:Debug('TransitionTo', state)
    self.timeInState = 0
    self.state = state
end

function ai:TransitionToReturn()
    -- Remove aggro target.
    self.aggroTarget = nil
    self:RemoveNegativeModifiers()
    self:KillAllSpiders()

    local target = self:GetEntity().spawn.spawnPoint + Vector(math.random(-64, 64), math.random(-64, 64))
    self:GetEntity():MoveToPosition(target) --Move back to the spawnpoint
    self.returnTarget = target
    self.state = ai.ACTION_RETURN --Transition the state to the 'Returning' state(!)
    self.returnTicks = 0
    self:Debug('Returning')
end

function ai:TransitionToIdle()
    --Go into the idle state
    self:TransitionTo(ai.ACTION_IDLE)
    self.returnTicks = nil
    self:Debug('Idling')
end

function ai:KillAllSpiders()
    -- Kill all spiders spawned
    for i = #self.spiders, 1, -1 do
        local spider = self.spiders[i]
        if spider and not spider:IsNull() then
            spider:ForceKill(false)
        end
    end
    self.spiders = {}
end

function ai:RemoveNegativeModifiers()
    -- Remove all negative modifiers.
    for _, modifier in pairs(self:GetEntity():FindAllModifiers()) do
        if modifier:GetName() ~= 'boss_modifier' then
            -- Proper Reset?
            self:Debug('Removing: ' .. modifier:GetName())
            modifier:Destroy()
        end
    end
end

------------
-- Basics
--
function ai:OnThink()
    if self:GetEntity():IsNull() then
        self:Debug('Died, should have been stopped already?')
        return
    end

    if self.isBusy then return end

    -- print('Tick: ', self.timeInState, self.timeSinceSummon, self.timeSinceBloom)

    self.timeInState = self.timeInState + 1
    if self.state ~= ai.ACTION_IDLE then
        self.timeSinceSummon = self.timeSinceSummon + 1
        self.timeSinceBloom = self.timeSinceBloom + 1
    end

    -- self:ActionIdle()
    Dynamic_Wrap(ai, self.state)(self)
end

function ai:OnDeath()
    getbase(ai).OnDeath(self)

    -- if self:GetEntity() ~= event.unit then return end
    self:Debug('OnDeath')
    self:GetEntity().spawn:OnDeath(self)

    Encounter:Log('Boss died, ending encounter.')
    Encounter:End()

    -- Takes a slight second for him to fall backwards.
    local pos = self:GetEntity():GetAbsOrigin()
    Timers:CreateTimer(0.45, function()
        ScreenShake(pos, 10, 150, 2.5, 3000, 0, true)
    end)
end

function ai:OnHeroDeath()
    if not Encounter.InEncounter or Encounter.ai ~= self then return end
    self:Debug('Wrap up encounter.')
    -- TODO: Review Targets
    Encounter:Log('A hero died, prematurely exiting.')
    Encounter:End()
end

-- Return, either hero died, or... probably hero died.
function ai:OnEncounterEnd()
    -- Check that we are still alive.
    if self:GetEntity() and self:GetEntity():IsAlive() then
        self:Debug('OnEncounterEnd -> TransitionToReturn')
        self:TransitionToReturn()
    end
end

function ai:GetHealthRegen()
    if self.state == ai.ACTION_RETURN then return self.passiveHealthRegen / 2 end
    if self.state == ai.ACTION_IDLE then return self.passiveHealthRegen end
    return 0
end

-----
-- Modifier
--

-- Modifier -- Won't work.
function ai:OnAttackAllied(event)
    self:Debug('OnAttackAllied PRE')
    if self:GetEntity() ~= event.target then return end
    self:Debug('OnAttackAllied')
end

-- Modifier -- Won't work.
function ai:OnTakeDamage(event)
    self:Debug('Someone or something took damage?')
    if self:GetEntity() ~= event.unit then return end

    if self.state == ai.ACTION_IDLE then
        self:Debug('Aggroing due to Attacked')
        self.aggroTarget = event.attacker
        self:StartFight()
    end
end
