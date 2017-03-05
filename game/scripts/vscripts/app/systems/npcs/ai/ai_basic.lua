ai_basic = ai_basic or class({})

ai_basic.BASIC_IDLE = 0
ai_basic.BASIC_ATTACK = 1

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
        self.iid = self:GetParent().myid
        self.state = ai_basic.BASIC_IDLE
        print('[AI BASIC] OnCreated')
        print(self:GetParent():GetUnitName())
        self:StartIntervalThink(1.0)
    end
end

---

-- function ai_basic:GetModifierIncomingDamage_Percentage()
--     print('Ouch, incoming damage.')
-- end

-- function ai_basic:OnTakeDamage(event)
--     -- It fires for EVERY instance...
--     if self:GetParent() ~= event.unit then return end
    
--     print('[AI BASIC] OnTakeDamage: ', self:GetParent().myid)
-- end


function ai_basic:Last()
    print('The last everything?')
end

function ai_basic:OnAttacked(event)
    -- It fires for EVERY instance...
    if self:GetParent() ~= event.target then return end
    print('[AI BASIC] OnAttacked')
    
    --Attack back
    -- if self.state == ai_basic.BASIC_IDLE then
    --     self.state = ai_basic.BASIC_ATTACK
    --     self.aggro = event.attacker
    --     event.target:MoveToTargetToAttack( event.attacker )
    --     EmitSoundOn('Hero_ShadowShaman.SheepHex.Target', event.target)
    -- end
end


function ai_basic:OnDeath()
    print('Oh there goes my life...')
end

function ai_basic:OnKill()
    print('Haha killed something...')
end
function ai_basic:OnHeroKilled()
    print('Oh I killed a hero...')
end

function ai_basic:OnStateChanged()
    -- print('[AI BASIC] ON STATE CHANGED')
end

function ai_basic:OnTakeDamageKillCredit()
    -- print('[AI BASIC] What is this method')
end

function ai_basic:OnIntervalThink()
    local entity = self:GetParent()
    if entity == nil then
        print('ENTITY NIL')
    elseif entity:IsNull() or not entity:IsAlive() then
        print('ENTITY DEAD')
        -- Spawner.totalAlive = Spawner.totalAlive - 1
        -- self.entity = nil
    else
        -- Alive.
        -- 10% chance to move.
        local rand = math.random(0, 10)
        if rand < 10 then return end
        
        if self.state == ai_basic.BASIC_IDLE then
            print('[SPAWN] Do Move ',self.iid)
            local target = entity.point + Vector(math.random(-256, 256), math.random(-256, 256))
            entity:MoveToPosition(target)
        end
    end
end
