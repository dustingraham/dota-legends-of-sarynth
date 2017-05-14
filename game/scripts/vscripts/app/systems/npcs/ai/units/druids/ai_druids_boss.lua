ai_druids_boss = ai_druids_boss or class({})
local ai = ai_druids_boss
function ai:IsDebuff() return false end
function ai:IsHidden() return true end

if IsServer() then
    AiBossActions(ai, 'zone_druids_boss', 'AiDruidsBoss')
    AiDruidsBossActions(ai)
    AiDruidsBossFire(ai)
    AiDruidsBossLogic(ai)
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

function ai:OnCreated(keys)
    if IsServer() then
        Debug('AiDruidsBoss', 'OnCreated')
        self.state = ai.ACTION_IDLE

        self.flames = {}
        self:FireIdle()

        self:StartIntervalThink(1.0)

        Event:Listen('HeroDeath', Dynamic_Wrap(ai, 'OnHeroDeath'), self)
    end
end

function ai:OnIntervalThink()
    self:FireTick()
    Dynamic_Wrap(ai, self.state)(self)
end

-----------------------------------------------------------------------------

function ai:GetModifierHealthRegenPercentage()
    if self.state == ai.ACTION_AGGRO then return 0.0 end
    return 20.0
end

function ai:GetModifierConstantHealthRegen()
    if self.state == ai.ACTION_AGGRO then return 0.0 end
    -- print(self:GetParent():GetUnitName(), self.passiveHealthRegen)
    return self.passiveHealthRegen
end

-----------------------------------------------------------------------------

function ai:OnTakeDamage(event)
    if self:GetParent() ~= event.unit then return end

    if event.attacker:IsRealHero() and event.attacker.currentZone ~= 'zone_druids_boss' then
        -- Damage attacker.
        self:Debug('Hero not in zone.')
        if not self.outOfZoneAttacks then self.outOfZoneAttacks = 0 end
        self.outOfZoneAttacks = self.outOfZoneAttacks + 1
        self:DealDamage(
        event.attacker,
        self.outOfZoneAttacks * event.attacker:GetMaxHealth() / 10,
        DAMAGE_TYPE_PURE
        )
    end

    if self.state == ai.ACTION_IDLE then
        self.aggroTarget = event.attacker
        self:StartFight()
    end
end

function ai:OnDeath(event)
    if self:GetParent() ~= event.unit then return end

    self:Debug('OnDeath')
    self:GetParent().spawn:OnDeath(self)

    Encounter:Log('Boss died, ending encounter.')
    Encounter:End()

    self:FireIdle()
    self:WallOff()

    -- Takes a slight second for him to fall backwards.
    EmitSoundOn('lone_druid_lone_druid_bearform_death_29', self:GetParent())
    local pos = self:GetParent():GetAbsOrigin()
    local maybe = self:GetParent()
    Timers:CreateTimer(0.25, function()
        ScreenShake(pos, 3, 100, 0.45, 2000, 0, true)
        Timers:CreateTimer(0.60, function()
            ScreenShake(pos, 10, 700, 1.50, 2000, 0, true)
            Timers:CreateTimer(0.45, function()
                EmitSoundOn('lone_druid_lone_druid_bearform_death_03', maybe)
            end)
        end)
    end)
end

function ai:OnHeroDeath(e, event)
    if Encounter.InEncounter and Encounter.ai == self then
        self:Debug('Hero died, checking for other living targets.')
        self:ReviewTargets()
        if self.aggroTarget and self.aggroTarget:IsAlive() then
            self:Debug('Found a live one, continuing fight.')
            Encounter:Log('Found a live one, continuing fight.')
            self:AttackTarget()
        else
            self:Debug('No living targets, ending encounter.')
            Encounter:Log('No living targets, ending encounter.')
            Encounter:End()
        end
    end
end

-- Return, either hero died, or... probably hero died.
function ai:OnEncounterEnd()
    -- Check that we are still alive.
    if self:GetParent() and self:GetParent():IsAlive() then
        self:Debug('OnEncounterEnd -> TransitionToReturn')
        self:TransitionToReturn()
    end
end
