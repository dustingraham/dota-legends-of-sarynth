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

function ai:constructor(entity)
    getbase(ai).constructor(self, entity)

    self.state = ai.ACTION_IDLE
    self.isBusy = false
    self.aggroRange = 400
    self.leashRange = 2000
    self.timeInState = 0
    self.timeSinceSummon = 0
    self.timeSinceBloom = 30

    self.startLocation = self:GetEntity():GetAbsOrigin()

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

-- Modifier -- Won't work.
function ai:OnDeath()
    getbase(ai).OnDeath(self)

    -- if self:GetEntity() ~= event.unit then return end
    self:Debug('OnDeath')
    self:GetEntity().spawn:OnDeath(self)

    --Encounter:Log('Boss died, ending encounter.')
    --Encounter:End()
    -- Takes a slight second for him to fall backwards.
    local pos = self:GetEntity():GetAbsOrigin()
    Timers:CreateTimer(0.45, function()
        ScreenShake(pos, 10, 150, 2.5, 3000, 0, true)
    end)
end
