ai_webbed_queen = ai_webbed_queen or class({}, nil, ai_core)
local ai = ai_webbed_queen
AiMixin(ai)

function ai:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_ATTACK_ALLIED,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
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

ai.TRANSITION = 'ActionTransition'
ai.ACTION_IDLE = 'ActionIdle'
ai.ACTION_RETURN = 'ActionReturn'
--ai.ACTION_AGGRO = 'ActionAggro'

ai.ACTION_FIGHT_STANDARD = 'ActionFightStandard'
ai.ACTION_POISON = 'ActionPoison'

ai.intervalDuration = 1
if IsServer() then
    function ai:OnCreated(keys)
        Debug('AiWebbedQueen', 'OnCreated')
        self.state = ai.ACTION_IDLE
        Debug('AiWebbedQueen', 'Idling OC')
        self.aggroRange    = 1000
        self.leashRange    = 1850
        self.timeInState   = 0

        self.startLocation = self:GetParent():GetAbsOrigin()
        -- self.aggroRange = self:GetParent().spawn.spawnNode.AggroRange or 400
        -- self.leashRange = self:GetParent().spawn.spawnNode.LeashRange or 750
        print('ID: ',self.intervalDuration)
        self:StartIntervalThink(self.intervalDuration)
    end
end

function ai:OnIntervalThink()
    self.timeInState = self.timeInState + self.intervalDuration
    Dynamic_Wrap(ai, self.state)(self)
end

function ai:GetModifierHealthRegenPercentage()
    if self.state == ai.ACTION_RETURN then return 10.0 end
    if self.state == ai.ACTION_IDLE then return 20.0 end
    return 0.0
end

function ai:OnAttackAllied(event)
    Debug('AiWebbedQueen', 'OnAttackAllied PRE')
    if self:GetParent() ~= event.target then return end
    Debug('AiWebbedQueen', 'OnAttackAllied')
end

function ai:OnTakeDamage(event)
    if self:GetParent() ~= event.unit then return end

    if self.state == ai.ACTION_IDLE then
        Debug('AiWebbedQueen', 'Aggroing due to Attacked')
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
    Debug('AiWebbedQueen', 'Starting fight state.')
    self.state = ai.ACTION_FIGHT_STANDARD
    --Encounter:Start(self:GetParent(), self.aggroTarget)

    self:AnimatedFace(self.aggroTarget, function()
        Timers(0.25, function()
            print('RAWR')
            -- Start attack.
            self:GetParent():MoveToTargetToAttack(self.aggroTarget)
        end)
    end)

    -- Howl and attack.
    --EmitSoundOn('Hero_Lycan.Howl', self:GetParent())

    --StartAnimation(self:GetParent(), {
    --    duration = 3.0,
    --    activity = ACT_DOTA_CAST_ABILITY_2,
    --    rate = 0.35,
    --})

    --Timers:CreateTimer(3.0, function()
    --    if self:IsNull() or self:GetParent():IsNull() then Debug('AiWebbedQueen', 'Too fast dead') return end
    --    Debug('AiWebbedQueen', 'Starting Attack')
    --    self:GetParent():MoveToTargetToAttack(self.aggroTarget)
    --end)
end

function ai:ActionTransition()
    -- Ensure we are not here too long...
    print(self.timeInState)
end

function ai:ActionIdle()
    local units = self:FindHeroes(self.aggroRange)

    --If one or more units were found, start attacking the first one
    if #units > 0 then
        Debug('AiWebbedQueen', 'Aggroing due to Range')
        self.aggroTarget = units[1]
        self:StartFight()
        return
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

function ai:TransitionToPoison()
    self.timeInState = 0
    self.state = ai.TRANSITION

    -- Move to poison.
    self:GetParent():MoveToPosition(self.startLocation)

    print('move to it...')
    print(self.startLocation)

    -- TODO: Remove duplicate move range check...
    local rangeSquared = 50 * 50
    Timers(function()
        -- stunned?
        --self:GetParent():MoveToPosition(self.startLocation)
        local distance = self:GetParent():GetAbsOrigin() - self.startLocation
        local rangeCurrent = distance.x * distance.x + distance.y * distance.y
        -- Check if position is inside the range.
        if rangeCurrent <= rangeSquared then
            -- Stop the move to position.
            self:GetParent():Stop()
            self.timeInState = 0
            self.state = ai.ACTION_POISON
            return nil
        end
        return 0.03
    end)
end

function ai:FireTheThing(speed)

--    local ability = self:GetParent():GetAbilityByIndex(0)
--    ability:SetLevel(1)
--    -- ability:CastAbility()
--
--    ExecuteOrderFromTable({
--        UnitIndex = self:GetParent():entindex(),
--        OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
--        AbilityIndex = 0, --ability:entindex(),
--        TargetIndex = self.aggroTarget:entindex()
--    })
--DeepPrintTable({
--                   UnitIndex = self:GetParent():entindex(),
--                   OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
--                   AbilityIndex = ability:entindex(),
--                   TargetIndex = self.aggroTarget:entindex()
--               })
--    print(ability:GetName())
--
--    do return end
    local caster = self:GetParent()
    local distance 	 	 = 1200
    local toss_speed 	 = speed
    local target_points = self.aggroTarget:GetAbsOrigin()
    local direction_toss = ( target_points - caster:GetAbsOrigin() ):Normalized()

    local projectile = {
        Ability             = nil, -- ability,
        EffectName          = 'particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf',
        vSpawnOrigin        = caster:GetAbsOrigin(),
        fDistance           = distance,
        fStartRadius        = 80,
        fEndRadius          = 80,
        Source              = caster,
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
        --  fExpireTime         = ,
        bDeleteOnHit        = false,
        vVelocity           = direction_toss * toss_speed,
        bProvidesVision     = false,
        --  iVisionRadius       = ,
        --  iVisionTeamNumber   = caster:GetTeamNumber(),
    }

    print('fire!')

    ProjectileManager:CreateLinearProjectile(projectile)
    do return end

    toss({
        caster = self:GetParent(),
        target_points = self.aggroTarget:GetAbsOrigin()
    })
    do return end
    ArcProjectile(self.round, {
        owner = self.hero,
        from = self:GetPos() + Vector(0, 0, 128),
        to = self.target,
        speed = 3200,
        arc = 600,
        graphics = self.hero:GetMappedParticle("particles/wk_w/wk_w.vpcf"),
        hitParams = {
            ability = self.ability,
            filter = Filters.Area(self.target, 200),
            filterProjectiles = true,
            damage = self.ability:GetDamage(),
            modifier = { name = "modifier_wk_w", duration = 2.0, ability = self.ability }
        },
        hitScreenShake = true,
        hitFunction = function(projectile, hit)
            if hit then
                projectile:EmitSound("Arena.WK.HitW2")
            else
                projectile:EmitSound("Arena.WK.HitW")
            end

            Spells:GroundDamage(self.target, 200, self.hero)
        end
    }):Activate()
end

function toss(args)
    local distance 	 	 = 1200
    local toss_speed 	 = 600
    local direction_toss = ( args.target_points - caster:GetAbsOrigin() ):Normalized()

    local projectile = {
        Ability             = nil, -- ability,
        EffectName          = particle_toss,
        vSpawnOrigin        = caster:GetAbsOrigin(),
        fDistance           = distance,
        fStartRadius        = 80,
        fEndRadius          = 80,
        Source              = caster,
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_ENEMY,
        --  iUnitTargetFlags    = ,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
        --  fExpireTime         = ,
        bDeleteOnHit        = false,
        vVelocity           = direction_toss * toss_speed,
        bProvidesVision     = false,
        --  iVisionRadius       = ,
        --  iVisionTeamNumber   = caster:GetTeamNumber(),
    }

    ProjectileManager:CreateLinearProjectile(projectile)
end

function volly(args)
    local caster = args.caster
    local info =
    {
        Ability = args.ability,
        EffectName = args.EffectName,
        iMoveSpeed = args.MoveSpeed,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = args.FixedDistance,
        fStartRadius = args.StartRadius,
        fEndRadius = args.EndRadius,
        Source = args.caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC+ DOTA_UNIT_TARGET_OTHER,
        bDeleteOnHit = true,
        vVelocity = 0.0,
    }
    for i=-40,40,20 do
        info.vSpawnOrigin = caster:GetAbsOrigin()+RotatePosition(Vector(0,0,0), QAngle(0,90,0), caster:GetForwardVector()) * i*10
        info.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), caster:GetForwardVector()) * args.MoveSpeed
        projectile = ProjectileManager:CreateLinearProjectile(info)
    end
end

function ai:ActionPoison()
    print('Time to poison:', self.timeInState)

    -- Face them
    if self.timeInState == 1 then
        print('Lets do something interesting...')
        self:GetParent():Stop()
        self:AnimatedFace(self.aggroTarget, function()
            Timers(0.25, function()
                print('ACT_DOTA_CAST_ABILITY_1')
                StartAnimation(self:GetParent(), {
                    duration = 1.0,
                    activity = ACT_DOTA_CAST_ABILITY_1,
                })
                self:FireTheThing(500)
            end)
            Timers(2.00, function()
                print('ACT_DOTA_CAST_ABILITY_1')
                StartAnimation(self:GetParent(), {
                    duration = 1.0,
                    activity = ACT_DOTA_CAST_ABILITY_1,
                    rate = 1.5,
                })
                self:FireTheThing(500)
            end)
            Timers(4.00, function()
                print('ACT_DOTA_CAST_ABILITY_1')
                StartAnimation(self:GetParent(), {
                    duration = 1.0,
                    activity = ACT_DOTA_CAST_ABILITY_1,
                    rate = 0.5,
                })
                self:FireTheThing(500)
            end)
        end)
    end

    if self.timeInState > 6 then
        self.timeInState = 0
        self.state = ai.ACTION_FIGHT_STANDARD
        self:GetParent():MoveToTargetToAttack(self.aggroTarget)
    end
end

--function ai:ActionAggro()
function ai:ActionFightStandard()

    -- After 5 seconds, do a thing.
    if self.timeInState >= 9 then
        self:TransitionToPoison()
        return true
    end

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
            Debug('AiWebbedQueen', 'Removing: '..modifier:GetName())
            modifier:Destroy()
        end
    end

    local target = self:GetParent().spawn.spawnPoint + Vector(math.random(-64, 64), math.random(-64, 64))
    self:GetParent():MoveToPosition( target ) --Move back to the spawnpoint
    self.returnTarget = target
    self.state = ai.ACTION_RETURN --Transition the state to the 'Returning' state(!)
    self.returnTicks = 0
    Debug('AiWebbedQueen', 'Returning')
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
        Debug('AiWebbedQueen', 'Could not return in 10 ticks, safety idling.')
        self:TransitionToIdle()
        return true
    end
end

function ai:TransitionToIdle()
    --Go into the idle state
    self.state = ai.ACTION_IDLE
    self.returnTicks = nil
    Debug('AiWebbedQueen', 'Idling')
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
