---
--@type QuestGiver
QuestGiver = QuestGiver or class({})

function QuestGiver:Init()
    CustomGameEventManager:RegisterListener('questgiver_dialog_event', Dynamic_Wrap(QuestGiver, 'OnQuestDialogEvent', QuestGiver))
end

function QuestGiver:LightOn(quest)
    self:LightOnAct(quest, quest.start_entity)
end
function QuestGiver:LightOnEnd(quest)
    self:LightOnAct(quest, quest.end_entity)
end
function QuestGiver:LightOnAct(quest, npc_name)
    if self.particle then return end
    
    self.quest = quest
    
    -- TEMP HACK 2...
    local entity = SpawnService:GetUnique(npc_name)
    entity.quest = quest
    self.entity = entity
    
    -- CreateParticleForPlayer -- Only that player sees it.
    self.particle = ParticleManager:CreateParticle(
        "particles/quest_available.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self.entity
    )
end

function QuestGiver:LightOff(quest)
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        self.particle = nil
    end
    
    -- Purge current quest data.
    self.quest = nil
    self.QuestID = nil
    self.entity = nil
end


--[[
    TODO: Whut whut... non-static?
]]

-- function QuestGiver:OpenQuestDialog(PlayerID)
--     --local QuestID = '1001'
--     print('[ERROR] THOUGHT WE WERE NOT HERE')
--     local QuestID = QuestGiver.QuestID
--     QuestService:OnOpenQuestDialog(QuestID, PlayerID, QuestGiver.quest)
-- end

function QuestGiver:OnQuestDialogEvent(event)
    --local QuestID = '1001'
    
    local choice = event.result
    if choice == 1 then
        Debug('QuestGiver', 'Quest accepted.')
        -- TODO: Destroy just for that character.
        QuestGiver:LightOff()
        
        -- Can't trust the client, so we have to remember what's open.
        local player = PlayerResource:GetPlayer(event.PlayerID)
        local QuestID = player.currentDialogForQuestID
        QuestService:OnQuestStart(QuestID, event.PlayerID)
    end
end

if not QuestGiver.initialized then
    QuestGiver.initialized = true
    QuestGiver:Init()
end

--[[

-- Stop Particle
if indicators[playerid] ~= nil then
    ParticleManager:DestroyParticle(indicators[playerid], false)
end

-- Start Particle
if not indicators[playerid] then
    indicators[playerid] = ParticleManager:CreateParticleForPlayer("name", PATTACH_ABSORIGIN_FOLLOW, hero, hero:GetPlayerOwner())
end

]]