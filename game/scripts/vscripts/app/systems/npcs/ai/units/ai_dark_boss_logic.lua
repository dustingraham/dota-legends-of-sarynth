--[[
Fight

Start:
 - Begin attacking hero.
 - Casts fireballs regularly throughout the fight to be side stepped.

75% HP:
 - Spawn one shard that gives a stacking armor buff to priestess.

50% HP:
 - Spawn one shard that gives a stacking armor buff to priestess.

25% HP:
 - Spawn one/two shards that gives a stacking armor buff to priestess.
 - Priestess runs to ball, links, energizes.

Shard Die:
 - Priestess: "Noooo...."
 - Shard explodes for aoe damage.

Energized:
 - Casts spells faster.
 - Double attack rate.

TODO: Make priestess path/phase through units when moving to the portal/particle.
 - MODIFIER_STATE_NO_UNIT_COLLISION
TODO: Check that summon spawn position is gridnav safe.

--]]
function AiDarkBossLogic(ai)

    -- Fight Starts, attack for 5 seconds.
    function ai:ActionFightStandard()
        -- TODO: Check for unit closer than target if target is running away.

        --Check if the unit's target is still alive (self.aggroTarget will have to be set when transitioning into this state)
        if not self.aggroTarget:IsAlive() then
            -- TODO Look for another target in the area!!
            -- local alternate = self:FindClosestAggro
            -- FindHeroesInArea (With our zone, or have attacked us.)
            self:TransitionToReturn()
            return true --Return to make sure no other code is executed in this state
        end

        self:ReviewAbilityDesire()

        --if self.timeInState > 5 then
        -- Cast Skill
        --end
        if self.shardOne == false then
            if self:GetParent():GetHealth() / self:GetParent():GetMaxHealth() < 0.75 then
                self.shardOne = self:CreateShard()
            end
        elseif self.shardTwo == false then
            if self:GetParent():GetHealth() / self:GetParent():GetMaxHealth() < 0.50 then
                self.shardTwo = self:CreateShard()
            end
        elseif self.shardThree == false then
            if self:GetParent():GetHealth() / self:GetParent():GetMaxHealth() < 0.25 then
                self.shardThree = self:CreateShard()
                self.shardFour = self:CreateShard()
                self:TransitionToEnergize()
            end
        end

        -- Keep track of shards up.
        self:UpdateShardCount()

        --State behavior
        --Here we can just do any behaviour you want to repeat in this state
        if not self:GetParent():IsAttacking() then
            self:FallbackAttackCheck()
        end
    end
    function ai:TransitionToEnergize()
        EmitSoundOn('death_prophet_dpro_pain_22', self:GetParent())
        self:TransitionTo(ai.ACTION_LINK_DESIRE)
    end
    function ai:DealDamage(target, damage, damageType, source)
        if not source then source = self:GetParent() end
        if not damageType then damageType = DAMAGE_TYPE_MAGICAL end
        ApplyDamage({
                        victim = target,
                        attacker = source,
                        damage = damage,
                        damage_type = damageType
                    })
    end

    function ai:OnShardKilled(deadShard)
        --self:UpdateStackCount()

        -- TODO: Explosion and damage? And, damage spot?
        -- TODO: Noise.
        ParticleManager:ReleaseParticleIndex(ParticleManager:CreateParticle(
            'particles/units/heroes/hero_techies/techies_blast_off.vpcf',
            PATTACH_ABSORIGIN_FOLLOW,
            deadShard
        ))
        -- Deal 1800 damage in 1000 radius.
        for _,target in pairs(self:FindHeroes(1000)) do
            self:DealDamage(target, 800, DAMAGE_TYPE_MAGICAL, deadShard)
        end
        -- Deal an extra 3200 damage in a 400 radius.
        for _,target in pairs(self:FindHeroes(400)) do
            self:DealDamage(target, 4800, DAMAGE_TYPE_MAGICAL, deadShard)
        end

        self:UpdateShardCount()

        --for _,shard in pairs(self.shards) do
        --    if IsValidEntity(shard) and shard:IsAlive() then
        --        Debug('AiDarkBoss', 'At least one shard is still alive...')
        --        return
        --    end
        --end

        -- All shards have died, transition to link desire.
        -- IFF we are in the fight state.
        --if self.state == ai.ACTION_FIGHT_STANDARD then
        --    EmitSoundOn('death_prophet_dpro_pain_22', self:GetParent())
        --    self:TransitionTo(ai.ACTION_LINK_DESIRE)
        --end
    end

    -- Desires a link, walk to the sphere and start channeling once arrived.
    function ai:ActionLinkDesire()
        --Check if the AI unit has reached its spawn location yet
        if ( self.energyParticle:GetAbsOrigin() - self:GetParent():GetAbsOrigin() ):Length() < 1000 then
            self:GetParent():Stop()
            self:EnergyLinkStart()
            self:TransitionTo(ai.ACTION_LINK_CHANNEL)
            return
        end

        -- Keep attempting to move, in case we were stunned.
        self:GetParent():MoveToPosition( self.energyParticle:GetAbsOrigin() )

        --if self.returnTicks > 10 then
        --    Debug('AiDarkBoss', 'Could not return in 10 ticks, safety idling.')
        --    self:TransitionToIdle()
        --    return true
        --end
    end

    -- Channel for 5 seconds, small burst, then continue attacking.
    function ai:ActionLinkChannel()
        if self.timeInState > 3 then
            self.energized = true

            self:GetParent():SetRangedProjectileName('particles/units/dark_plains/boss/energized_attack/energized_attack.vpcf')

            self:EnergyLinkStop()
            self:AttackTarget()
            self:TransitionTo(ai.ACTION_FIGHT_STANDARD)
        end
    end

    function ai:TransitionTo(toState)
        Debug('AiDarkBoss', 'TransitionTo', toState)
        self.timeInState = 0
        self.state = toState
    end

    -- Return, either hero died, or... probably hero died.
    function ai:OnEncounterEnd()
        -- Check that we are still alive.
        if self:GetParent() and self:GetParent():IsAlive() then
            Debug('AiDarkBoss', 'OnEncounterEnd -> TransitionToReturn')
            self:TransitionToReturn()
        end
    end

    function ai:TransitionToReturn()
        Debug('AiDarkBoss', 'Transition To Return')
        self:ToggleWall(false)

        -- Reset various states created during fight.
        --self.shardsCreated = false -- Reset by "force kill" check action.

        self:EnergyLinkStop(true)
        self.energized = false
        self.hasLinked = false
        self.aggroTarget = nil
        -- Reset projectile if needed.
        self:GetParent():SetRangedProjectileName('particles/econ/items/queen_of_pain/qop_navi_mace/queen_base_attack_navi_mace.vpcf')

        -- Remove all negative modifiers.
        for _,modifier in pairs(self:GetParent():FindAllModifiers()) do
            if modifier ~= self then
                -- Proper Reset?
                Debug('AiDarkBoss', 'Removing: '..modifier:GetName())
                modifier:Destroy()
            end
        end

        -- Where we need to go
        local target = self:GetParent().spawn.spawnPoint + Vector(math.random(-64, 64), math.random(-64, 64))
        self:GetParent():MoveToPosition( target ) --Move back to the spawnpoint
        self.returnTarget = target
        self.returnTicks = 0

        self:TransitionTo(ai.ACTION_RETURN)

        -- Another full health insurance.
        self:GetParent():SetHealth(self:GetParent():GetMaxHealth())
    end

    -- In the process of returning.
    function ai:ActionReturn()
        --Check if the AI unit has reached its spawn location yet
        if ( self.returnTarget - self:GetParent():GetAbsOrigin() ):Length() < 10 then
            self:TransitionToIdle()
            return true
        end

        -- Keep attempting to move, in case we were stunned.
        self:GetParent():MoveToPosition( self.returnTarget ) --Move back to the spawnpoint

        -- Sometimes we can't get there...
        if self.timeInState > 10 then
            Debug('AiDarkBoss', 'Could not return in 10 ticks, safety idling.')
            self:TransitionToIdle()
            return true
        end
    end

    -- Made it back, transition to idle.
    function ai:TransitionToIdle()
        --Go into the idle state
        self:TransitionTo(ai.ACTION_IDLE)

        -- Another full health insurance.
        self:GetParent():SetHealth(self:GetParent():GetMaxHealth())
    end

    -- Idling around spawn point.
    function ai:ActionIdleMove()
        if self:GetParent():IsMoving() then return end

        -- 20% chance to move.
        local rand = math.random(0, 10)
        --Debug('AiDarkBoss', 'Random move:', rand)
        if rand < 5 then return end

        -- Move!
        local maxDist = 512
        local target = self:GetParent().spawn.spawnPoint + RandomVector(maxDist)
        --local target = self:GetParent().spawn.spawnPoint + Vector(math.random(-maxDist, maxDist), math.random(-maxDist, maxDist))
        self:GetParent():MoveToPosition(target)
    end
end
