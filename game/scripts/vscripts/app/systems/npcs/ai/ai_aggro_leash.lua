ai_aggro_leash = ai_aggro_leash or class({})
local ai = ai_aggro_leash

function ai:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,

        MODIFIER_EVENT_ON_ATTACK_ALLIED,

        --MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
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
        self:GetParent().ai = self
        self.state = ai.ACTION_IDLE
        self.castDesire = 0
        self.callForHelp = self:GetParent().spawn.spawnNode.CallForHelp or 0
        self.aggroRange = self:GetParent().spawn.spawnNode.AggroRange or 400
        self.leashRange = self:GetParent().spawn.spawnNode.LeashRange or 750
        self.passiveHealthRegen = Clamp(self:GetParent():GetMaxHealth() / 10, 0, 800)
        self:StartIntervalThink(1.0)
    end
end

function ai:IsHidden()
    return true
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
    Debug('AiAggroLeash', 'OnAttackAllied PRE')
    if self:GetParent() ~= event.target then return end
    Debug('AiAggroLeash', 'OnAttackAllied')
end

function ai:OnTakeDamage(event)
    if self:GetParent() ~= event.unit then return end

    if self.state == ai.ACTION_IDLE then
        Debug('AiAggroLeash', 'AggroOnTarget due to OnTakeDamage')
        self:AggroOnTarget(event.attacker)
    end
end

function ai:AggroOnTarget(target)
    --Start attacking
    self:GetParent():MoveToTargetToAttack(target)
    self.aggroTarget = target
    self.state = ai.ACTION_AGGRO --State transition

    -- self.callForHelp
    -- IdleMove: 196 + 196 average move range
    -- Spawn Jitter: 80 + 80
    -- ~552. Create 600 "call for help" radius...
    if self.callForHelp > 0 then
        -- Call for help in radius
        Debug('AiAggroLeash', 'Calling for help radius:', self.callForHelp)
        local callForHelp = FindUnitsInRadius(
        self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil,
        self.callForHelp, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER, false
        )
        if #callForHelp then
            for _,helper in ipairs(callForHelp) do
                Debug('AiAggroLeash', 'Call to arms:', helper:GetUnitName())
                if helper.ai then
                    helper.ai:CallForHelp(target)
                else
                    Debug('AiAggroLeash', 'No AI found to ask...')
                end
            end
        end
    end
end

function ai:CallForHelp(target)
    Debug('AiAggroLeash', 'Called by ally to help.')
    if self.state == ai.ACTION_IDLE then
        Debug('AiAggroLeash', 'Going to help!')
        self:GetParent():MoveToTargetToAttack(target)
        self.aggroTarget = target
        self.state = ai.ACTION_AGGRO --State transition
    else
        Debug('AiAggroLeash', 'Not idling...')
    end
end

function ai:OnDeath(event)
    if self:GetParent() ~= event.unit then return end
    Debug('AiAggroLeash', 'OnDeath')
    self:GetParent().spawn:OnDeath(self)

    -- TODO: Move this elsewhere.
    if self:GetParent():GetUnitName() == 'webbed_spidy_bubble' then
        local ticks = 0
        local position = self:GetParent():GetAbsOrigin()
        local entity = CreateUnitByName('webbed_spidy_bubble_death', position, true, nil, nil, DOTA_TEAM_NEUTRALS)

        -- Initial Cloud Visual
        local noxiousParticle = ParticleManager:CreateParticle(
        'particles/units/webbed/noxious_cloud.vpcf',
        PATTACH_CUSTOMORIGIN,
        entity
        )
        ParticleManager:SetParticleControl( noxiousParticle, 0, position )
        ParticleManager:SetParticleControl( noxiousParticle, 1, Vector(150, 0, 0))
        --ParticleManager:ReleaseParticleIndex(particle)

        -- Death Splat
        Timers(0.3, function()
            local particle = ParticleManager:CreateParticle(
            'particles/units/heroes/hero_broodmother/broodmother_spiderlings_spawn_b_lv.vpcf',
            PATTACH_CUSTOMORIGIN,
            entity
            )
            ParticleManager:SetParticleControl( particle, 0, position )
        end)

        -- Poison Cloud
        Timers:CreateTimer(1.25, function()
            ticks = ticks + 1
            if ticks < 20 then
                --local particle = ParticleManager:CreateParticle(
                --    "particles/econ/items/undying/undying_manyone/undying_pale_tombstone_cloud.vpcf",
                --    PATTACH_CUSTOMORIGIN,
                --    entity
                --)
                --ParticleManager:SetParticleControl( particle, 0, position )
                --ParticleManager:ReleaseParticleIndex(particle)

                -- Make the ouch
                local units = FindUnitsInRadius(
                DOTA_TEAM_GOODGUYS,
                position,
                nil,
                100,
                DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false
                )
                for _,ouchUnit in pairs(units) do
                    ouchUnit:AddNewModifier(entity, nil, 'webbed_spidy_bubble_death_cloud', { duration = 3 })
                end
                return 1
            else
                -- Stop the particle...
                ParticleManager:DestroyParticle(noxiousParticle, false)
                ParticleManager:ReleaseParticleIndex(noxiousParticle)

                -- Delay to destroy the entity, otherwise particle clips off.
                Timers(3, function()
                    -- TODO: Create a single global dummy entity.
                    entity:ForceKill(false)
                end)
            end
        end)
    end
end

function ai:OnIntervalThink()
    Dynamic_Wrap(ai, self.state)(self)
end

function ai:ActionIdle()
    local units = FindUnitsInRadius(
    self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil,
    self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER, false
    )
    --If one or more units were found, start attacking the first one
    if #units > 0 then
        Debug('AiAggroLeash', 'AggroOnTarget due to ActionIdle RadiusFind')
        self:AggroOnTarget(units[1])
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
                self:GetParent():CastAbilityOnTarget(self.aggroTarget, ability, -1)
                --self:GetParent():CastAbilityOnPosition(self.aggroTarget:GetAbsOrigin(), ability, -1)
                self.castDesire = 0
            else
                self.castDesire = self.castDesire + 20
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

    --local ability = self:GetParent():GetAbilityByIndex(1)
    --if ability then
    --    --print('=----=')
    --    --print(ability:GetName())
    --    --print('CD ', ability:IsCooldownReady())
    --    --print('Mana', ability:IsOwnersManaEnough())
    --    if ability:IsCooldownReady() and ability:IsOwnersManaEnough() then
    --        --self:GetParent():CastAbilityOnTarget(self.aggroTarget, ability, -1)
    --        ExecuteOrderFromTable({
    --            UnitIndex = self:GetParent():entindex(),
    --            OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
    --            AbilityIndex = ability:entindex(),
    --            TargetIndex = self.aggroTarget:entindex()
    --        })
    --    end
    --end
    --State behavior
    --Here we can just do any behaviour you want to repeat in this state
end

function ai:TransitionToReturn()
    -- Remove aggro target.
    self.aggroTarget = nil

    -- Remove all negative modifiers.
    for _,modifier in pairs(self:GetParent():FindAllModifiers()) do
        if modifier ~= self then
            -- Proper Reset?
            Debug('AiAggroLeash', 'Removing: '..modifier:GetName())
            modifier:Destroy()
        end
    end

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
