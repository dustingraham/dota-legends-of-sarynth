-- TODO: Create separate ModifierThinker for flames to persist through death.
function AiDruidsBossFire(ai)

    ai.CHANCE_INTERVAL = 10
    ai.WARNING_TIME = 4
    ai.BURN_TIME = 8

    -- "All lit" at around 120 seconds.
    ai.DOUBLE_TIME = 20

    function ai:FireOn()
        self:Debug('Starting fire...')
        self.fireOn = true
        self.fireTicks = 0
    end

    function ai:FireIdle()
        self.fireOn = false
        self.fireTicks = 0
        self.fireActions = {}
        self.fireStates = {}
        for i = 1, 6 do
            self:FlameState(i, 1)
        end
    end

    function ai:FireTick()
        if not self.fireOn then return end

        self.fireTicks = self.fireTicks + 1
        self:EvaluateActions()

        -- Create something new...
        if self.fireTicks % ai.CHANCE_INTERVAL == 0 then
            self:FireRandomSingle()
        end

        if self.fireTicks % ai.DOUBLE_TIME == 0 then
            --print('DOUBLE TIME')
            ai.BURN_TIME = ai.BURN_TIME + 2
            if ai.CHANCE_INTERVAL > 1 then
                ai.CHANCE_INTERVAL = ai.CHANCE_INTERVAL - 1
            end
            if ai.DOUBLE_TIME > 1 then
                ai.DOUBLE_TIME = ai.DOUBLE_TIME - 1
            end
        end
        local allLit = true
        for i = 1, 6 do
            if self.fireStates[i] ~= 3 then
                allLit = false
            end
        end
        if allLit and not self.allLit then
            self.allLit = self.fireTicks
            --self:Debug('ALL LIT at: ', self.fireTicks)
        end
    end

    function ai:FireRandomSingle()
        local pick = RandomInt(1,6)
        --self:Debug('TRY FIRE ', pick)
        if self.fireStates[pick] == 1 then
            -- Flame is idle, let's make it burn.
            self:FlameState(pick, 2)
            self.fireActions[pick] = self.fireTicks + ai.WARNING_TIME
        else
            -- Already burning...
            --self:Debug('Picked flame is not idle... state:', self.fireStates[pick])
        end
    end

    function ai:EvaluateActions()
        -- Check if we need to move to the next state.
        for id,time in pairs(self.fireActions) do
            if self.fireTicks == time then
                self:FireProgress(id)
            end
        end

        -- Check if we need to burn anyone!
        for id,state in pairs(self.fireStates) do
            if state == 3 then
                local pos = Entities:FindByName(nil, 'druids_boss_flame'..id):GetAbsOrigin()
                for _,target in pairs(self:FindHeroes(350, pos)) do
                    target:AddNewModifier(self:GetParent(), nil, 'druids_boss_fire', {duration = 2})
                end
            end
        end
    end

    function ai:FireProgress(id)
        local state = self.fireStates[id]
        if state == 2 then
            self:FlameState(id, 3)
            self.fireActions[id] = self.fireTicks + ai.BURN_TIME
        elseif state == 3 then
            self:FlameState(id, 1)
            self.fireActions[id] = nil
        else
            self:Debug('ERROR Unexpected state: ', state)
        end
    end

    --function ai:StartRandom()
    --    for i = 1, 6 do
    --        Timers(i, function()
    --            self:RandomCycle(i)
    --        end)
    --    end
    --end

    --function ai:RandomCycle(i)
    --    print(RandomFloat(0.25, 1.25))
    --
    --    Timers(RandomFloat(1.25, 3.25), function()
    --        self:FlameState(i, 2)
    --        Timers(RandomFloat(2.00, 3.00), function()
    --            self:FlameState(i, 3)
    --            Timers(RandomFloat(4.00, 6.00), function()
    --                self:FlameState(i, 1)
    --                self:RandomCycle(i)
    --            end)
    --        end)
    --    end)
    --end

    --function ai:FireAll()
    --    -- Red Particle
    --    for i = 1, 6 do
    --        Timers(i, function()
    --            self:FlameState(i, 2)
    --            Timers(2, function()
    --                self:FlameState(i, 3)
    --            end)
    --        end)
    --    end
    --end

    --function ai:SetLook2()
    --    -- Red Particle
    --    for i = 1, 4 do
    --        self:FlameState(i, 2)
    --    end
    --end
    --
    --function ai:SetLook3()
    --    for i = 1, 4 do
    --        self:FlameState(i, 3)
    --    end
    --end

    FLAME_STATE_PARTICLES = {
        'particles/econ/courier/courier_dc/dccourier_angel_flame_trail.vpcf',
        'particles/econ/courier/courier_dc/dccourier_devil_flame_trail.vpcf',
        'particles/units/heroes/hero_jakiro/jakiro_dual_breath_fire_d.vpcf',
    }

    function ai:FlameState(id, state)
        --print('Trying', id, state)
        self.fireStates[id] = state
        self:ParticleOff(id)
        local particleName = FLAME_STATE_PARTICLES[state]
        -- Debug('AiDruidsBoss', 'Particle on...', particleName)

        local pos = Entities:FindByName(nil, 'druids_boss_flame'..id):GetAbsOrigin()
        if state == 3 then
            pos = pos + Vector(0,0,25)
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
end
