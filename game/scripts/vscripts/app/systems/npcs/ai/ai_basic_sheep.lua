ai_basic_sheep = ai_basic_sheep or class({})

function ai_basic_sheep:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACKED,
        MODIFIER_EVENT_ON_DEATH
    }
end

if IsServer() then
    function ai_basic_sheep:OnCreated(keys)
        Debug('AiBasicSheep', 'OnCreated')
        self.lastHitTick = 9
        self:StartIntervalThink(1.0)
    end
end

function ai_basic_sheep:IsHidden() return true end

function ai_basic_sheep:OnAttacked(event)
    if self:GetParent() ~= event.target then return end
    Debug('AiBasicSheep', 'OnAttacked')

    if self.lastHitTick > 8 then
        self.lastHitTick = 0
        EmitSoundOn('Hero_ShadowShaman.SheepHex.Target', event.target)
        -- Freak out...
        local direction = (event.target:GetAbsOrigin() - event.attacker:GetAbsOrigin()):Normalized()
        local moveTo = event.target:GetAbsOrigin() + 100 * direction
        event.target:MoveToPosition(moveTo)
    end
end

function ai_basic_sheep:OnDeath(event)
    if self:GetParent() ~= event.unit then return end
    Debug('AiBasicSheep', 'OnDeath')
    self:GetParent().spawn:OnDeath(self)
end

function ai_basic_sheep:OnIntervalThink()
    self.lastHitTick = self.lastHitTick + 1

    -- Debug('AiBasicSheep', 'OnThink')

    -- 10% chance to move.
    if RollPercentage(90) then return end

    -- Move!
    local target = self:GetParent().spawn.spawnPoint + Vector(math.random(-256, 256), math.random(-256, 256))
    self:GetParent():MoveToPosition(target)

end
