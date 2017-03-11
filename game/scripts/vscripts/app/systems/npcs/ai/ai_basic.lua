ai_basic = ai_basic or class({})

function ai_basic:DeclareFunctions()
    return {
        -- MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        -- MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_ATTACKED,
        MODIFIER_EVENT_ON_STATE_CHANGED,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT,
        MODIFIER_EVENT_ON_HERO_KILLED,
        MODIFIER_FUNCTION_LAST
    }
end

if IsServer() then
    function ai_basic:OnCreated()
        Debug('AiBasic', 'OnCreated')
        print(self:GetParent():GetUnitName())
    end
end

---

-- function ai_basic:GetModifierIncomingDamage_Percentage()
--     Debug('AiBasic', 'Ouch, incoming damage.')
-- end

-- function ai_basic:OnTakeDamage(event)
--     -- It fires for EVERY instance...
--     if self:GetParent() ~= event.unit then return end
    
--     Debug('AiBasic', 'OnTakeDamage: ', self:GetParent().myid)
-- end


function ai_basic:Last()
    Debug('AiBasic', 'The last everything?')
end

function ai_basic:OnAttacked(event)
    -- It fires for EVERY instance...
    if self:GetParent() ~= event.target then return end
    Debug('AiBasic', 'OnAttacked')
end

function ai_basic:OnDeath(event)
    if self:GetParent() ~= event.unit then return end
    Debug('AiBasic', 'OnDeath')
    self:GetParent().spawn:OnDeath(self)
end

function ai_basic:OnKill()
    Debug('AiBasic', 'Haha killed something...')
end
function ai_basic:OnHeroKilled()
    Debug('AiBasic', 'Oh I killed a hero...')
end

function ai_basic:OnStateChanged()
    -- Debug('AiBasic', 'ON STATE CHANGED')
end

function ai_basic:OnTakeDamageKillCredit()
    -- Debug('AiBasic', 'What is this method')
end
