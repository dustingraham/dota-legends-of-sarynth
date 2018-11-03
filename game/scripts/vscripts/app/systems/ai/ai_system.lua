AiSystem = AiSystem or class({}, {
    registered = {},
    ai_table = {},
}, System)

function AiSystem:Activate()
    ListenToGameEvent('entity_killed', Dynamic_Wrap(AiSystem, 'OnEntityKilled'), AiSystem)
    self:StartThinker()
end
Event:BindActivate(AiSystem)


function AiSystem:OnThink()
    for i = #self.ai_table, 1, -1 do
        -- WrapException

        self.ai_table[i]:OnThink()
    end
end

function AiSystem:StartThinker()
    self.timer = Timers:CreateTimer(function()
        AiSystem:OnThink()
        return 1.0
    end)
end

function AiSystem:OnEntityKilled(event)
    local killed = EntIndexToHScript(event.entindex_killed);
    if killed.ai then
        killed.ai:OnDeath()
        self:RemoveAi(killed.ai)
    end
    --local killed_name = killed:GetUnitName();
    --DeepPrintTable(event)
end

function AiSystem:OnSpawn(entity, aiName)
    local aiType = self:Find(aiName)
    local ai = aiType(entity)
    self:AddAi(ai)
    return ai
end

function AiSystem:AddAi(ai)
    table.insert(self.ai_table, ai)
end

function AiSystem:RemoveAi(ai)
    -- Consider flag for removal, and remove on next iteration?
    for k,v in ipairs(self.ai_table) do
        if ai == v then
            table.remove(self.ai_table, k)
            break
        end
    end
end

function AiSystem:Find(name)
    return self.registered[name]
end

function AiSystem:Register(ai)
    self.registered[ai.name] = ai
end
