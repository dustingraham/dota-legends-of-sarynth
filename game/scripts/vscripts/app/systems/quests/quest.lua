---
-- @type Quest
Quest = Quest or class({
    -- TODO: Defaults...
    -- id = -1,
    -- title = 'Missing',
    -- objective = 'Missing',
    -- current = 0,
    -- required = 1,
    -- npcs = {}
})

---
-- @function [parent=#Quest] constructor
-- @param #number PlayerID
-- @param #table questData
function Quest:constructor(PlayerID, questData)
    self.PlayerID = PlayerID
    TableMerge(self, questData)
    for k,v in pairs(self.objectives) do
        if v.current == nil then
            v.current = 0
        end
    end
end

function Quest:GetStartNpc()
    if not self.startNpc then
        self.startNpc = SpawnSystem:GetUnique(self.start_entity)
    end
    return self.startNpc
end

function Quest:GetEndNpc()
    if not self.endNpc then
        self.endNpc = SpawnSystem:GetUnique(self.end_entity)
    end
    return self.endNpc
end

function Quest:GetName()
    return self.name
end

--function Quest:SetQuestGiver(questgiver)
--    self.questgiver = questgiver
--end

function Quest:IsComplete()
    for k,v in pairs(self.objectives) do
        if v.current < v.required then
            return false
        end
    end
    return true
end

function Quest:ApplyReward(hero)
    if self.rewards.experience then
        hero:AddExperience(self.rewards.experience, 0, false, false)
        SendOverheadEventMessage( hero:GetPlayerOwner(), OVERHEAD_ALERT_XP , hero, self.rewards.experience, nil )
    end
end

function Quest:Accept()
    -- self.PlayerID
    -- local player = PlayerResource:GetPlayer(event.PlayerID)
    self:GetStartNpc():ParticleOff(QuestService.questParticleName)
end

function Quest:Complete()
    -- self.PlayerID
    -- local player = PlayerResource:GetPlayer(event.PlayerID)
    self:GetEndNpc():ParticleOff(QuestService.questParticleName)
end

-- Get reduced data set for client transmission.
function Quest:GetData()
    -- Just enough to present client side display.
    
    -- (icon) Title
    -- [current] / [required] [description]
    
    local data = {
        icon = self.icon,
        title = self.title,
        objectives = {},
    }
    for _,objective in pairs(self.objectives) do
        local oData = {
            current = objective.current,
            required = objective.required,
            description = objective.description,
        }
        table.insert(data.objectives, oData)
    end
    return data
end

-- Get reduced data set for client transmission.
function Quest:GetStartData()
    -- Just enough to present client side display.
    
    -- (icon) Title
    -- [current] / [required] [description]
    
    local data = {
        icon = self.icon,
        title = self.title,
        dialog_text = self.start.dialog,
        objectives = {},
        rewards = self.rewards,
    }
    for _,objective in pairs(self.objectives) do
        local oData = {
            current = objective.current,
            required = objective.required,
            description = objective.description,
            long_description = objective.long_description,
        }
        table.insert(data.objectives, oData)
    end
    
    Debug('Quest', inspect(data))
    return data
end

-- Get reduced data set for client transmission.
function Quest:GetEndData()
    -- Just enough to present client side display.
    
    -- (icon) Title
    -- [current] / [required] [description]
    
    local data = {
        icon = self.icon,
        title = self.title,
        dialog_text = self.complete.dialog,
        rewards = self.rewards,
    }
    
    Debug('Quest', inspect(data))
    return data
end

---
--@function [parent=#Quest] OnEntityKilled
--@param self
--@param #string npc_name
function Quest:OnEntityKilled(npc_name)
    -- Check each objective.
    for _,objective in pairs(self.objectives) do
        -- Do nothing if we alredy have required number.
        if objective.current ~= objective.required then
            local npcMatch = false
            for _,npc in pairs(objective.npc) do
                if npc == npc_name then
                    npcMatch = true
                    break
                end
            end
            if npcMatch then
                objective.current = objective.current + 1
                QuestService:SendQuestUpdate(self)
                if self:IsComplete() then
                    self:GetEndNpc():ParticleOn(QuestService.questParticleName)
                end
            end
        end
    end
end
