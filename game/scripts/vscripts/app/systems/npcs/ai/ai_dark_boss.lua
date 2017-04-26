ai_dark_boss = ai_dark_boss or class({})
local ai = ai_dark_boss

function ai:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        --MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
end

ai.ACTION_IDLE = 'ActionIdle'
ai.ACTION_RETURN = 'ActionReturn'
ai.ACTION_FIGHT_STANDARD = 'ActionFightStandard'

if IsServer() then
    function ai:OnCreated(keys)
        Debug('AiDarkBoss', 'OnCreated Idling')
        self.state = ai.ACTION_IDLE

        self.castDesire = 0
        self.testTicks = 0

        self.shardsCreated = 0
        self.shards = {}

        self.aggroRange = 850
        self.leashRange = 2000
        self.passiveHealthRegen = Clamp(self:GetParent():GetMaxHealth() / 10, 0, 800)
        self:StartIntervalThink(1.0)
    end
end

--function ai:GetModifierHealthRegenPercentage()
--    if self.state == ai.ACTION_RETURN then return 10.0 end
--    if self.state == ai.ACTION_IDLE then return 20.0 end
--    return 0.0
--end

function ai:GetModifierConstantHealthRegen()
    if self.state == ai.ACTION_RETURN then return self.passiveHealthRegen / 2 end
    if self.state == ai.ACTION_IDLE then return self.passiveHealthRegen end
    -- print(self:GetParent():GetUnitName(), self.passiveHealthRegen)
    return 0
end

function ai:OnTakeDamage(event)
    if self:GetParent() ~= event.unit then return end

    if self.state == ai.ACTION_IDLE then
        Debug('AiDarkBoss', 'Aggroing due to Attacked')
        self.aggroTarget = event.attacker
        self:StartFight()
    end
    if self.state == ai.ACTION_FIGHT_STANDARD then
        if self.shardsCreated == 0 then
            if self:GetParent():GetHealth() / self:GetParent():GetMaxHealth() < 0.5 then
                self:CreateShards()
            end
        end
    end
end

function ai:OnDeath(event)
    if self:GetParent() ~= event.unit then return end
    Debug('AiDarkBoss', 'OnDeath')
    self:GetParent().spawn:OnDeath(self)

    Encounter:Log('Boss died, ending encounter.')
    Encounter:End()
    self:ToggleWall(false)

    -- Takes a slight second for him to fall backwards.
    local pos = self:GetParent():GetAbsOrigin()
    Timers:CreateTimer(0.25, function()
        ScreenShake(pos, 3, 100, 0.35, 2000, 0, true)
    end)
    EmitSoundOn('death_prophet_dpro_defeat_04', self:GetParent())
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
    Debug('AiDarkBoss', 'Starting fight state.')
    self.state = ai.ACTION_FIGHT_STANDARD
    self:ToggleWall(true)

    Encounter:Start(self:GetParent(), self.aggroTarget)

    EmitSoundOn('death_prophet_dpro_spawn_03', self:GetParent())
    self:GetParent():MoveToTargetToAttack(self.aggroTarget)
    --StartAnimation(self:GetParent(), {
    --    duration = 3.0,
    --    activity = ACT_DOTA_CAST_ABILITY_2,
    --    rate = 0.35,
    --})
    --Timers:CreateTimer(3.0, function()
    --    Debug('AiDarkBoss', 'Starting Attack')
    --    self:GetParent():MoveToTargetToAttack(self.aggroTarget)
    --end)

    --Timers:CreateTimer(5.0, function()
    --    if self.state == ai.ACTION_FIGHT_STANDARD then
    --        if not self:GetParent():IsNull() and self:GetParent():IsAlive() then
    --            self:CreateShards()
    --        end
    --    end
    --end)
end

function ai:CreateShards()
    Debug('AiDarkBoss', 'Creating shards...')
    EmitSoundOn('death_prophet_dpro_laugh_012', self:GetParent())

    self.shardsCreated = 1
    local caster = self:GetParent()
    local caster_location = caster:GetAbsOrigin()

    local shard1 = CreateUnitByName('dark_boss_summons', caster_location + RandomVector(200), true, caster, caster, caster:GetTeamNumber())
    shard1:MoveToTargetToAttack( self.aggroTarget )
    table.insert(self.shards, shard1)
    local shard2 = CreateUnitByName('dark_boss_summons', caster_location + RandomVector(200), true, caster, caster, caster:GetTeamNumber())
    shard2:MoveToTargetToAttack( self.aggroTarget )
    table.insert(self.shards, shard2)
    Timers(1.0, function()
        if IsValidEntity(shard1) then
            shard1:MoveToTargetToAttack( self.aggroTarget )
        end
        if IsValidEntity(shard2) then
            shard2:MoveToTargetToAttack( self.aggroTarget )
        end
    end)
end

function ai:KillShards()
    for _,s in pairs(self.shards) do
        if s and IsValidEntity(s) then
            s:ForceKill(false)
        end
    end
    self.shards = {}
    self.shardsCreated = 0
end

function ai:ActionIdle()
    --self.testTicks = self.testTicks + 1
    --if self.testTicks > 5 then
    --    --Debug('AiDarkBoss', 'Test Interval')
    --    self.testTicks = 0
    --end

    local units = FindUnitsInRadius(
    self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil,
    self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER, false
    )

    --If one or more units were found, start attacking the first one
    if #units > 0 then
        Debug('AiDarkBoss', 'Aggroing due to Range')
        self.aggroTarget = units[1]
        self:StartFight()
        return true
    end

    self:ActionIdleMove()
end

function ai:ToggleWall(toggleTo)
    local particle = Entities:FindByName(nil, 'dark_barricade_particle')
    -- Create the dummy if we don't have one already.
    if not self.dummyEntity then
        self.dummyEntity = CreateUnitByName('dummy_entity', particle:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
    end
    -- Toggle the wall
    if self.toggleWall then
        self.toggleWall = false
        ParticleManager:DestroyParticle(self.particleIndex, false)
        ParticleManager:ReleaseParticleIndex(self.particleIndex)
        self.particleIndex = nil
        -- Opening wall, kill shards.
        self:KillShards()
    else
        self.toggleWall = true
        self.particleIndex = ParticleManager:CreateParticle('particles/dire_fx/bad_ancient_ambient.vpcf', PATTACH_ABSORIGIN, self.dummyEntity)
        ParticleManager:SetParticleControl(self.particleIndex, 0, particle:GetAbsOrigin())
    end

    Debug('AiDarkBoss', 'Wall toggled to:', self.toggleWall)
    if self.toggleWall ~= toggleTo then
        Debug('AiDarkBoss', 'DANGER Wall Mismatch....')
    end

    -- Toggle the simple obstructions
    for _,obstruction in pairs(Entities:FindAllByName('dark_barricade_obstruction')) do
        obstruction:SetEnabled(self.toggleWall, false)
    end
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

function ai:ReviewAbilityDesire()
    -- Concept
    --self:GetParent():AddAbility('ranger_poison_arrow')
    --Timers:CreateTimer(5.0, function()
    --    local ability = self:GetParent():FindAbilityByName('ranger_poison_arrow')
    --    self:GetParent():CastAbilityOnTarget(units[1], ability, -1)
    --end)
    local ability = self:GetParent():GetAbilityByIndex(0)
    if ability then
        --print('=----=')
        --print(ability:GetName())
        --print('FC', ability:IsFullyCastable())
        --print('IA', self:GetParent():IsAttacking())
        --print('CD ', ability:IsCooldownReady())
        --print('Mana', ability:IsOwnersManaEnough())
        if ability:IsFullyCastable() then
            local roll = math.random(100)
            if roll < self.castDesire then
                --self:GetParent():CastAbilityOnTarget(self.aggroTarget, ability, -1)
                self:GetParent():CastAbilityOnPosition(self.aggroTarget:GetAbsOrigin(), ability, -1)
                self.castDesire = 0
            else
                self.castDesire = self.castDesire + 10
            end
            --print('DO IT:', 'Go cast fool.')
            --ExecuteOrderFromTable({
            --      UnitIndex = self:GetParent():entindex(),
            --      OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
            --      AbilityIndex = ability:entindex(),
            --      TargetIndex = self.aggroTarget:entindex()
            --  })
        else
            if not self:GetParent():IsAttacking() then
                --print('DO IT: ', 'Go attack fool.')
                self:GetParent():MoveToTargetToAttack( self.aggroTarget )
            end
        end
    end

end

--function ai:ActionAggro()
function ai:ActionFightStandard()
    --Check if the unit has walked outside its leash range
    if ( self:GetParent().spawn.spawnPoint - self:GetParent():GetAbsOrigin() ):Length() > self.leashRange then
        self:TransitionToReturn()
        return true --Return to make sure no other code is executed in this state
    end

    -- TODO: Check for unit closer than target if target is running away.

    --Check if the unit's target is still alive (self.aggroTarget will have to be set when transitioning into this state)
    if not self.aggroTarget:IsAlive() then
        -- TODO Look for another target in the area!!
        self:TransitionToReturn()
        return true --Return to make sure no other code is executed in this state
    end

    self:ReviewAbilityDesire()

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
            Debug('AiDarkBoss', 'Removing: '..modifier:GetName())
            modifier:Destroy()
        end
    end

    local target = self:GetParent().spawn.spawnPoint + Vector(math.random(-64, 64), math.random(-64, 64))
    self:GetParent():MoveToPosition( target ) --Move back to the spawnpoint
    self.returnTarget = target
    self.state = ai.ACTION_RETURN --Transition the state to the 'Returning' state(!)
    self.returnTicks = 0
    self:ToggleWall(false)
    Debug('AiDarkBoss', 'Returning')
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
        Debug('AiDarkBoss', 'Could not return in 10 ticks, safety idling.')
        self:TransitionToIdle()
        return true
    end
end

function ai:TransitionToIdle()
    --Go into the idle state
    self.state = ai.ACTION_IDLE
    self.returnTicks = nil
    Debug('AiDarkBoss', 'Idling')
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
