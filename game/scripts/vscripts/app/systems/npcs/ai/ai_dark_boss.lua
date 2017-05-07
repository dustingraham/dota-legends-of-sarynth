ai_dark_boss = ai_dark_boss or class({
    numShards = 0,
})
local ai = ai_dark_boss
function ai:IsDebuff() return false end

if IsServer() then
    AiDarkBossActions(ai)
    AiDarkBossLogic(ai)
end

function ai:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
end

ai.ACTION_IDLE           = 'ActionIdle'
ai.ACTION_RETURN         = 'ActionReturn'
ai.ACTION_FIGHT_STANDARD = 'ActionFightStandard'

ai.ACTION_LINK_DESIRE    = 'ActionLinkDesire'
ai.ACTION_LINK_CHANNEL   = 'ActionLinkChannel'

ai.INITIAL_STATE         = ai.ACTION_IDLE

ai.intervalDuration = 1
if IsServer() then
    function ai:OnCreated(keys)
        --self.state = ai.ACTION_IDLE
        self.state = ai.INITIAL_STATE
        Debug('AiDarkBoss', 'OnCreated State to:', self.state)

        self.energyParticle = Entities:FindByName(nil, 'dark_barricade_particle')

        self.castDesire = 0
        self.testTicks = 0
        self.timeInState   = 0
        self.outOfZoneAttacks = 0
        self.noTargetsFound = 0

        --self:SetStackCount(0)
        self.numShards = 0
        self.shardOne = false
        self.shardTwo = false
        self.shardThree = false
        self.shardFour = false
        --self.shardsCreated = false
        --self.shards = {}

        self.aggroRange = 850
        self.leashRange = 2000
        self.passiveHealthRegen = Clamp(self:GetParent():GetMaxHealth() / 10, 0, 800)
        self:StartIntervalThink(self.intervalDuration)
        Event:Listen('HeroDeath', Dynamic_Wrap(ai, 'OnHeroDeath'), self)
    end
end

function ai:OnIntervalThink()
    self.timeInState = self.timeInState + self.intervalDuration
    Dynamic_Wrap(ai, self.state)(self)
end

-- Slower speed while idling.
function ai:GetModifierMoveSpeedOverride()
    if self.state == ai.ACTION_IDLE then return 220 end
    return 360
end

function ai:GetModifierAttackSpeedBonus_Constant()
    if self.energized then return 80 end
    return 0
end

function ai:GetModifierConstantHealthRegen()
    if self.state == ai.ACTION_RETURN then return self.passiveHealthRegen / 2 end
    if self.state == ai.ACTION_IDLE then return self.passiveHealthRegen end
    -- print(self:GetParent():GetUnitName(), self.passiveHealthRegen)
    return 0
end

function ai:GetModifierIncomingDamage_Percentage()
    return -60 * self.numShards
end

function ai:OnTakeDamage(event)
    if self:GetParent() ~= event.unit then return end
    if self:GetParent() == event.attacker then Debug('AiDarkBoss', 'Self ForceKill') return end

    if event.attacker:IsRealHero() and event.attacker.currentZone ~= 'zone_dark_boss' then
        -- Damage attacker.
        Debug('AiDarkBoss', 'Hero not in zone.')
        self.outOfZoneAttacks = self.outOfZoneAttacks + 1
        self:DealDamage(
            event.attacker,
            self.outOfZoneAttacks * event.attacker:GetMaxHealth() / 10,
            DAMAGE_TYPE_PURE
        )
    end

    if self.state == ai.ACTION_IDLE then
        Debug('AiDarkBoss', 'Aggroing due to Attacked')
        self.aggroTarget = event.attacker
        self.rangedTarget = event.attacker
        self:StartFight()
    end

    -- Rather than checking for mods on every attack.... we ought to have a mod if there's one up.
    -- Just flash!
    if self.numShards > 0 then
        self:ShieldFlash()
    end
end

function ai:ShieldFlash()
    local pIdx = ParticleManager:CreateParticle(
    'particles/units/dark_plains/boss/shield_deflection.vpcf',
    PATTACH_ABSORIGIN_FOLLOW,
    self:GetParent()
    )
    ParticleManager:SetParticleControl(pIdx, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(pIdx)
end

function ai:GetTexture()
    return 'invoker_forge_spirit'
end

function ai:IsHidden() return self:GetStackCount() == 0 end

function ai:UpdateShardCount()
    local count = 0
    if self.shardOne and IsValidEntity(self.shardOne) and self.shardOne:IsAlive() then
        count = count + 1
    end
    if self.shardTwo and IsValidEntity(self.shardTwo) and self.shardTwo:IsAlive() then
        count = count + 1
    end
    if self.shardThree and IsValidEntity(self.shardThree) and self.shardThree:IsAlive() then
        count = count + 1
    end
    if self.shardFour and IsValidEntity(self.shardFour) and self.shardFour:IsAlive() then
        count = count + 1
    end
    self.numShards = count
    self:SetStackCount(count)
end

function ai:OnDeath(event)
    if event.unit == self.shardOne or event.unit == self.shardTwo or event.unit == self.shardThree or event.unit == self.shardFour then
        self:OnShardKilled(event.unit)
    end
    if self:GetParent() ~= event.unit then return end

    Debug('AiDarkBoss', 'OnDeath')
    self:GetParent().spawn:OnDeath(self)

    Encounter:Log('Boss died, ending encounter.')
    Encounter:End()
    self:ToggleWall(false)

    -- Clean Up.... Ensure not making noise...
    self:EnergyLinkStop(true)

    -- Takes a slight second for him to fall backwards.
    local pos = self:GetParent():GetAbsOrigin()
    Timers:CreateTimer(0.25, function()
        ScreenShake(pos, 3, 100, 0.35, 2000, 0, true)
    end)
    EmitSoundOn('death_prophet_dpro_defeat_04', self:GetParent())
end

function ai:OnHeroDeath(e, event)
    if Encounter.InEncounter and Encounter.ai == self then
        Debug('AiDarkBoss', 'Hero died, checking for other living targets.')
        self:ReviewTargets()
        if self.aggroTarget and self.aggroTarget:IsAlive() then
            Debug('AiDarkBoss', 'Found a live one, continuing fight.')
            Encounter:Log('Found a live one, continuing fight.')
            self:AttackTarget()
        else
            Debug('AiDarkBoss', 'No living targets, ending encounter.')
            Encounter:Log('No living targets, ending encounter.')
            --self:OnEncounterEnd()
            Encounter:End()
        end
    end
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

    EmitSoundOn('death_prophet_dpro_spawn_03', self:GetParent())
    self:ToggleWall(true)

    -- TODO: Report all heroes in area.
    Encounter:Start(self:GetParent(), self.aggroTarget, self)

    self:TransitionTo(ai.ACTION_FIGHT_STANDARD)
    self:AttackTarget()
end

function ai:ActionIdle()
    --If one or more units are found in aggro range, start attacking the first one
    local units = self:FindHeroes(self.aggroRange)
    if #units > 0 then
        Debug('AiDarkBoss', 'Aggroing due to Range')
        self.aggroTarget = units[1]
        self.rangedTarget = units[1]
        self:StartFight()
        return true
    end

    self:ActionIdleMove()
end

function ai:ReviewAbilityDesire()
    --if not self.hasLinked and self.timeInState > 5 then
    --    self:TransitionTo(ai.ACTION_LINK_DESIRE)
    --    self.hasLinked = true
    --    return
    --end

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
        local distance = (self.rangedTarget:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D()

        if ability:IsFullyCastable() and distance > 250 then
            local roll = math.random(100)
            if roll < self.castDesire then
                --self:GetParent():CastAbilityOnTarget(self.aggroTarget, ability, -1)
                self:GetParent():CastAbilityOnPosition(self.rangedTarget:GetAbsOrigin(), ability, -1)
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
                self:AttackTarget()
            end
        end
    end
end

function ai:AttackTarget()
    -- Consider checking if state is "standard fight" otherwise bug may occur, where
    -- during her link, if a hero dies, she begins to attack the remaining hero before link is over.
    self:GetParent():MoveToTargetToAttack(self.aggroTarget)
end

-- If we get stuck somewhere, start attacking after 5 seconds.
function ai:FallbackAttackCheck()
    if self.fallbackCheck == nil then
        self.fallbackCheck = 0
    end
    self.fallbackCheck = self.fallbackCheck + 1
    if self.fallbackCheck > 5 then
        self:AttackTarget()
        self.fallbackCheck = nil
    end
end

function ai:FindHeroes(range, sourcePosition)
    sourcePosition = sourcePosition or self:GetParent():GetAbsOrigin()
    return FindUnitsInRadius(
    self:GetParent():GetTeam(),
    sourcePosition,
    nil,
    range,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_ALL,
    DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER,
    false
    )
end

