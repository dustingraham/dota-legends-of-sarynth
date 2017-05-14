ai_druids_boss = ai_druids_boss or class({})
local ai = ai_druids_boss

--function ai:DeclareFunctions()
--    return {
--        MODIFIER_EVENT_ON_DEATH,
--        MODIFIER_EVENT_ON_TAKEDAMAGE,
--        MODIFIER_EVENT_ON_ATTACK_ALLIED,
--    }
--end

ai.ACTION_IDLE = 'ActionIdle'
ai.ACTION_AGGRO = 'ActionAggro'
ai.ACTION_RETURN = 'ActionReturn'

function ai:OnCreated(keys)
    if IsServer() then
        Debug('AiDruidsBoss', 'OnCreated')
        self.state = ai.ACTION_IDLE
        self.aggroCycle = 0
        self.detectRange = 600
        self.flames = {}
        self:StartIntervalThink(1.0)

        self:SetLook1()
        --self:StartRandom()
    end
end

function ai:StartRandom()
    for i = 1, 6 do
        Timers(i, function()
            self:RandomCycle(i)
        end)
    end
end

function ai:RandomCycle(i)
    print(RandomFloat(0.25, 1.25))

    Timers(RandomFloat(1.25, 3.25), function()
        self:FlameState(i, 2)
        Timers(RandomFloat(2.00, 3.00), function()
            self:FlameState(i, 3)
            Timers(RandomFloat(4.00, 6.00), function()
                self:FlameState(i, 1)
                self:RandomCycle(i)
            end)
        end)
    end)
end

function ai:IncrementAggroCycle()
    if self.aggroCycle < 6 then self.aggroCycle = self.aggroCycle + 1 end
    self.activityLevel = 'level'..self.aggroCycle
    Debug('AiDruidsBoss', 'ActivityLevel', self.activityLevel)
end

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

-- ACT_DOTA_ATTACK - Appears to be the fully closed state.
-- ACT_DOTA_IDLE+level1+showcase = weird fast moving, test!
-- ACT_DOTA_CAPTURE - just the ball
-- ACT_DOTA_CAPTURE+level1 - various modes of open
-- ACT_DOTA_CONSTANT_LAYER+level1 - appears similar to capture.
-- ACT_DOTA_IDLE+level2+showcase - appears to be the transition from level1 to level2?

function ai:TransitionToAggro()
    Debug('AiDruidsBoss', 'Aggroing')

    self.state = ai.ACTION_AGGRO --State transition

    self:FireAll()

    --self:SetLook2()
    --Timers(5, function()
    --    self:SetLook3()
    --end)
end

function ai:TransitionToReturn()
    -- Remove aggro target.
    self.aggroTarget = nil

    -- self:SetStackCount(0)
    self:SetLook1()

    -- Remove all negative modifiers.
    self:ModPurge() -- Also removes activity modifiers!
    self.state = ai.ACTION_IDLE --Transition the state to the 'Returning' state(!)

    Debug('AiDruidsBoss', 'Returning to Idle')
end


function ai:TransitionToIdle()
    self.state = ai.ACTION_IDLE

    Debug('AiDruidsBoss', 'Idling')
end



-----------------------------------------------------------------------------

function ai:IsHidden()
    return true
end

function ai:CheckState()
    return {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_STUNNED] = true,
    }
end

function ai:GetModifierHealthRegenPercentage()
    if self.state == ai.ACTION_AGGRO then return 0.0 end
    return 20.0
end

function ai:GetModifierConstantHealthRegen()
    if self.state == ai.ACTION_AGGRO then return 0.0 end
    -- print(self:GetParent():GetUnitName(), self.passiveHealthRegen)
    return self.passiveHealthRegen
end

function ai:OnAttackAllied(event)
    Debug('AiDruidsBoss', 'OnAttackAllied PRE')
    if self:GetParent() ~= event.target then return end
    Debug('AiDruidsBoss', 'OnAttackAllied')
end

function ai:OnTakeDamage(event)
    if self:GetParent() ~= event.unit then return end

    if self.state == ai.ACTION_IDLE then
        self:GetParent():MoveToTargetToAttack( event.attacker ) --Start attacking
        self.aggroTarget = event.attacker
        self.state = ai.ACTION_AGGRO --State transition
        Debug('AiDruidsBoss', 'Aggroing')
    end
end

function ai:OnDeath(event)
    if self:GetParent() ~= event.unit then return end
    Debug('AiDruidsBoss', 'OnDeath')
    self:GetParent().spawn:OnDeath(self)
end

function ai:OnIntervalThink()
    Dynamic_Wrap(ai, self.state)(self)
end

function ai:ActionIdle()
    local units = FindUnitsInRadius(
    self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil,
    self.detectRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER, false
    )
    --If one or more units were found, start attacking the first one
    if #units > 0 then
        self.aggroTarget = units[1]
        self:TransitionToAggro()
        return true
    end
end

function ai:ActionAggro()
    --Check if the unit has walked outside its detect range
    if ( self.aggroTarget:GetAbsOrigin() - self:GetParent():GetAbsOrigin() ):Length() > self.detectRange then
        self:TransitionToReturn()
    end
end

------------------------------------------------------
-- Misc Helpers
--

function ai:SetLook1()
    for i = 1, 6 do
        self:FlameState(i, 1)
    end
end

function ai:FireAll()
    -- Red Particle
    for i = 1, 6 do
        Timers(i, function()
            self:FlameState(i, 2)
            Timers(2, function()
                self:FlameState(i, 3)
            end)
        end)
    end
end

function ai:SetLook2()
    -- Red Particle
    for i = 1, 4 do
        self:FlameState(i, 2)
    end
end

function ai:SetLook3()
    for i = 1, 4 do
        self:FlameState(i, 3)
    end
end

FLAME_STATE_PARTICLES = {
    'particles/econ/courier/courier_dc/dccourier_angel_flame_trail.vpcf',
    'particles/econ/courier/courier_dc/dccourier_devil_flame_trail.vpcf',
    'particles/units/heroes/hero_jakiro/jakiro_dual_breath_fire_d.vpcf',
}
function ai:FlameState(id, state)
    self:ParticleOff(id)
    local particleName = FLAME_STATE_PARTICLES[state]
    --Debug('AiDruidsBoss', 'Particle on...', particleName)

    local pos = Entities:FindByName(nil, 'druids_boss_flame'..id):GetAbsOrigin()
    if state == 3 then
        pos = pos + Vector(0,0,50)
    end

    local idx = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(idx, 0, pos)
    ParticleManager:SetParticleControl(idx, 1, pos)
    ParticleManager:SetParticleControl(idx, 2, pos)
    ParticleManager:SetParticleControl(idx, 3, pos)
    self.flames[id] = idx
end

function ai:ParticleOff(id)
    if self.flames[id] then
        ParticleManager:DestroyParticle(self.flames[id], false)
        ParticleManager:ReleaseParticleIndex(self.flames[id])
        self.flames[id] = nil
    end
end


function ai:ModPurge()
    for _,modifier in pairs(self:GetParent():FindAllModifiers()) do
        if modifier ~= self then
            -- Proper Reset?
            Debug('AiDruidsBoss', 'Removing: '..modifier:GetName())
            modifier:Destroy()
        end
    end
end

