ai_basic_aggro = ai_basic_aggro or class({})

function ai_basic_aggro:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACKED,
        MODIFIER_EVENT_ON_DEATH,
        
        -- Hoping for some "onIdleAcquire" but may need to build it myself.
        MODIFIER_EVENT_ON_ORDER,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_EVENT_ON_STATE_CHANGED,
        MODIFIER_EVENT_ON_ATTACK_ALLIED,
    }
end

if IsServer() then
    function ai_basic_aggro:OnCreated(keys)
        Debug('AiBasicAggro', 'OnCreated')
        self:StartIntervalThink(1.0)
    end
end

function ai_basic_aggro:OnAttackAllied(event)
    if self:GetParent() ~= event.target then return end
    Debug('AiBasicAggro', 'OnAttackAllied')
end
function ai_basic_aggro:OnStateChanged(event)
    if self:GetParent() ~= event.target then return end
    Debug('AiBasicAggro', 'OnStateChanged')
end
function ai_basic_aggro:OnAttackStart(event)
    if self:GetParent() ~= event.target then return end
    Debug('AiBasicAggro', 'OnAttackStart')
end
function ai_basic_aggro:OnAttack(event)
    if self:GetParent() ~= event.target then return end
    Debug('AiBasicAggro', 'OnAttack')
end
function ai_basic_aggro:OnOrder(event)
    if self:GetParent() ~= event.target then return end
    Debug('AiBasicAggro', 'OnOrder')
end

function ai_basic_aggro:OnAttacked(event)
    if self:GetParent() ~= event.target then return end
    Debug('AiBasicAggro', 'OnAttacked')
end

function ai_basic_aggro:OnDeath(event)
    if self:GetParent() ~= event.unit then return end
    Debug('AiBasicAggro', 'OnDeath')
    self:GetParent().spawn:OnDeath(self)
end

function ai_basic_aggro:OnIntervalThink()
    -- 10% chance to move.
    local rand = math.random(0, 10)
    if rand < 10 then return end
    
    -- Move!
    local target = self:GetParent().spawn.spawnPoint + Vector(math.random(-196, 196), math.random(-196, 196))
    self:GetParent():MoveToPosition(target)
end
