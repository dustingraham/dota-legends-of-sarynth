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
        if v.action == 'kill' and v.current == nil then
            v.current = 0
        end
        if v.action == 'collect' and v.current == nil then
            v.current = 0
        end
        if v.action == 'report' and v.reported == nil then
            v.reported = false
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
        if v.action == 'kill' and v.current < v.required then
            return false
        end
        if v.action == 'collect' and v.current < v.required then
            return false
        end
        if v.action == 'report' and not v.reported then
            return false
        end
    end
    return true
end

function Quest:TakeQuestItems(hero)
    -- Check each objective, and banish the items.
    for _,objective in pairs(self.objectives) do
        -- Also checking that we lost items and no longer fill objective.
        if objective.action == 'collect' then
            local count = 0
            for _,itemName in pairs(objective.item) do
                -- Destroy it
                hero.inventory:RemoveItemsByName(itemName)
            end
        end
    end
end

function Quest:ApplyReward(hero)
    if self.rewards.experience then
        hero:AddExperience(self.rewards.experience, DOTA_ModifyXP_Unspecified, false, true)
        PopupExperience(hero, self.rewards.experience)
    end
    if self.rewards.gold then
        hero:ModifyGold(self.rewards.gold, true, DOTA_ModifyGold_Unspecified)
        PopupGoldGain(hero, self.rewards.gold)
    end
    if self.rewards.item_choose then
        local item = CreateItem(self.rewards.item_choose['01'], nil, nil)
        InventoryService:AddItem(hero, item)
        if hero.firstQuestItem == nil then
            hero.firstQuestItem = true
            -- hero.customInventory:Open(hero:GetPlayerOwnerID())
        end
    end
end

function Quest:Accept()
    -- self.PlayerID
    -- local player = PlayerResource:GetPlayer(event.PlayerID)
    self:GetStartNpc():ParticleOffForPlayer(QuestService.questParticleName, self.PlayerID)

    -- Check for report to objectives.
    for _,objective in pairs(self.objectives) do
        if objective.action == 'report' and not objective.reported then
            -- TODO: We may not always want the end NPC. This won't work for that.
            Debug('Quest', 'Light up the end npc.')
            self:GetEndNpc():ParticleOnForPlayer(QuestService.questParticleName, self.PlayerID)
        end
    end
end

function Quest:Complete()
    -- self.PlayerID
    -- local player = PlayerResource:GetPlayer(event.PlayerID)
    self:GetEndNpc():ParticleOffForPlayer(QuestService.questParticleName, self.PlayerID)
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
        if objective.action == 'kill' and objective.current ~= objective.required then
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
                    local player = PlayerResource:GetPlayer(self.PlayerID)
                    EmitSoundOnClient('powerup_06', player)
                    self:GetEndNpc():ParticleOnForPlayer(QuestService.questParticleName, self.PlayerID)
                end
            end
        end
    end
end

function Quest:OnInventoryChange(hero, item)
    -- Check each objective.
    for _,objective in pairs(self.objectives) do
        -- Also checking that we lost items and no longer fill objective.
        if objective.action == 'collect' then
            local count = 0
            for _,itemName in pairs(objective.item) do
                --print('Check '..itemName)
                count = count + hero.inventory:GetItemCount(itemName)
                --print('Just testing, all item count: ', count)
            end
            objective.current = math.min(objective.required, count)
            --print('Just testing, current: ', objective.current)
            QuestService:SendQuestUpdate(self)
            -- TODO: turn it back off if lose items?
            if self:IsComplete() then
                local player = PlayerResource:GetPlayer(self.PlayerID)
                EmitSoundOnClient('powerup_06', player)
                self:GetEndNpc():ParticleOnForPlayer(QuestService.questParticleName, self.PlayerID)
            end
        end
    end
end

-- TODO: This is the "name" of the entity. Not the unique name. TODO: Lookup the unique name. (?)
function Quest:OnEntityInteract(npc_name)
    for _,objective in pairs(self.objectives) do
        if objective.action == 'report' and not objective.reported then
            Debug('Quest', ' needs interaction ')
            print(inspect(objective))
            local npcMatch = false
            for _,npc in pairs(objective.npc) do
                if npc == npc_name then
                    npcMatch = true
                    break
                end
            end
            if npcMatch then
                Debug('Quest', 'Reported to report target.')
                self:GetEndNpc():ParticleOffForPlayer(QuestService.questParticleName, self.PlayerID)
                objective.reported = true
            end
        end
    end
end
