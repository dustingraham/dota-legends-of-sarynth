ai_spider_queen = ai_spider_queen or class({}, nil, ai_core)
local ai = ai_spider_queen

-- For some reason, it seems the LUA modifier when the modifier is created
-- it does not gain the properties of ai_core.
-- Consider using WrapAi() or moving ai to a separate class.
-- Probably want inheritance, so Modifier does if IsServer then self.ai = SpiderAI()



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

]]--
ai.ACTION_IDLE = 'ActionIdle'
ai.ACTION_SUMMON = 'ActionSummon'
ai.ACTION_ATTACK = 'ActionAttack'
ai.ACTION_BLOOM = 'ActionBloom'

function ai:OnCreated(keys)
    if not IsServer() then return end
    Debug('AiSpiderQueen', 'OnCreated')

    self.state = ai.ACTION_IDLE
    self.isBusy = false
    self.aggroRange = 1000
    self.leashRange = 2000
    self.timeInState = 0
    self.timeSinceSummon = 0
    self.timeSinceBloom = 30

    self.startLocation = self:GetParent():GetAbsOrigin()
    self:StartIntervalThink(1)
end

------------
-- Logic
--


function ai:StartFight()
    Debug('AiSpiderQueen', 'Starting fight state.')

    self:TransitionTo(ai.ACTION_SUMMON)

    -- Howl and attack.
    --EmitSoundOn('Hero_Lycan.Howl', self:GetParent())
end

function ai:ActionSummon()
    self:SummonWolfSpider()
    self:TransitionTo(ai.ACTION_ATTACK)
end

function ai:ActionAttack()
    self:AttackTarget()

    -- TODO: Check desire to fire triplicate.
    -- TODO: Check desire to fire single at ranged.

    -- At 30 seconds, then each 60 seconds.
    if self.timeSinceBloom > 6 then
        self:TransitionTo(ai.ACTION_BLOOM)
        return
    end

    -- At 0 seconds, then each 60 seconds.
    if self.timeSinceSummon > 6 then
        self:TransitionTo(ai.ACTION_SUMMON)
        return
    end
end

function ai:ActionSummon()
    self:ExecutePoisonBloom()
    self:TransitionTo(ai.ACTION_ATTACK)
end

function ai:ActionIdle()
    print('Is: ', IsServer())
    --If one or more units are found in aggro range, start attacking the first one
    local units = self:FindHeroes(self.aggroRange)
    if #units > 0 then
        self:Debug('Aggroing due to Range')
        self.aggroTarget = units[1]
        self.rangedTarget = units[1]
        self:StartFight()
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
            self:GetParent():MoveToTargetToAttack(self.aggroTarget)
        end)
    end)
end
function ai:AttackTarget()
    self:GetParent():MoveToTargetToAttack(self.aggroTarget)
end
function ai:TransitionTo(state)
    self:Debug('TransitionTo', state)
    self.timeInState = 0
    self.state = state
end

------------
-- Basics
--

function ai:Debug(...)
    Debug('AiSpiderQueen', ...)
end

function ai:OnIntervalThink()
    if self.isBusy then return end

    self.timeInState = self.timeInState + 1
    self.timeSinceSummon = self.timeSinceSummon + 1
    self.timeSinceBloom = self.timeSinceBloom + 1

    self:ActionIdle()
    -- Dynamic_Wrap(ai, self.state)(self)
end

function ai:OnAttackAllied(event)
    Debug('AiSpiderQueen', 'OnAttackAllied PRE')
    if self:GetParent() ~= event.target then return end
    Debug('AiSpiderQueen', 'OnAttackAllied')
end

function ai:OnTakeDamage(event)
    Debug('AiSpiderQueen', 'Someone or something took damage?')
    if self:GetParent() ~= event.unit then return end

    if self.state == ai.ACTION_IDLE then
        Debug('AiSpiderQueen', 'Aggroing due to Attacked')
        self.aggroTarget = event.attacker
        self:StartFight()
    end
end

function ai:OnDeath(event)
    if self:GetParent() ~= event.unit then return end
    Debug('AiWebbedQueen', 'OnDeath')
    self:GetParent().spawn:OnDeath(self)

    --Encounter:Log('Boss died, ending encounter.')
    --Encounter:End()
    -- Takes a slight second for him to fall backwards.
    local pos = self:GetParent():GetAbsOrigin()
    Timers:CreateTimer(0.45, function()
        ScreenShake(pos, 10, 150, 2.5, 3000, 0, true)
    end)
end



--------------
-- Functions
--

function ai:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_ATTACK_ALLIED,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
    }
end

function ai:GetModifierHealthRegenPercentage()
    if self.state == ai.ACTION_RETURN then return 10.0 end
    if self.state == ai.ACTION_IDLE then return 20.0 end
    return 0.0
end
