AiSystem = AiSystem or class({}, {
    registered = {},
    ai_table = {},
}, System)

function AiSystem:Activate()
    ListenToGameEvent('entity_killed', Dynamic_Wrap(AiSystem, 'OnEntityKilled'), AiSystem)
    Filters:OnModifierGainedFilter(Dynamic_Wrap(AiSystem, 'OnModifierGainedFilter'), AiSystem)
    Event:Listen('HeroDeath', Dynamic_Wrap(AiSystem, 'OnHeroDeath'), AiSystem)
    self:StartThinker()
end
Event:BindActivate(AiSystem)


function AiSystem:OnThink()
    for i = #self.ai_table, 1, -1 do
        WrapException(function(i)
            self.ai_table[i]:OnThink()
        end, i)
    end
end

function AiSystem:StartThinker()
    self.timer = Timers:CreateTimer(function()
        AiSystem:OnThink()
        return 1.0
    end)
end

function AiSystem:OnHeroDeath(event)
    self:Debug('OnHeroDeath')

    for i = #self.ai_table, 1, -1 do
        WrapException(function(i)
            self.ai_table[i]:OnHeroDeath(event.params)
        end, i)
    end
end

function AiSystem:OnEntityKilled(event)
    local killed = EntIndexToHScript(event.entindex_killed);
    if killed.ai then
        -- Check if this is a "new" AI.
        if instanceof(killed.ai, AiBase) then
            killed.ai:OnDeath()
            self:RemoveAi(killed.ai)
        end
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



function AiSystem:OnModifierGainedFilter(event)
    local parent = EntIndexToHScript(event.params.entindex_parent_const)

    -- 1) If this is the boss, don't take stuns.
    if parent:IsBoss() then
        local stuns = {
            ranger_concussion = true,
            mage_ice_shocked = true,
            rogue_incapacitated = true,
            sorcerer_blasted = true,
            warrior_bashed = true,
        }
        if stuns[event.params.name_const] then
            -- self:Debug('Stun Aversion')
            return false
        end
    end

    --if event.params.name_const == 'ai_basic_sheep' then return end
    --if event.params.name_const == 'ai_aggro_leash' then return end

    -- DeepPrintTable(event)

    --local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)

    return true
end

function AiSystem:Debug(...)
    Debug('AiSystem', ...)
end
