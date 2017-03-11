---
--@type QuestGiver
QuestGiver = QuestGiver or class({})

--function QuestGiver:Init()
--    CustomGameEventManager:RegisterListener('questgiver_dialog_event', Dynamic_Wrap(QuestGiver, 'OnQuestDialogEvent', QuestGiver))
--end

--function QuestGiver:LightOn(quest)
--    self:LightOnAct(quest, quest.start_entity)
--end
--function QuestGiver:LightOnEnd(quest)
--    self:LightOnAct(quest, quest.end_entity)
--end
--local questParticleName = "particles/quest_available.vpcf"
--function QuestGiver:LightOnAct(quest, npc_name)
--    
--    local entity = SpawnSystem:GetUnique(npc_name)
--    if not entity then return end
--    
--    entity:ParticleOn(questParticleName)
--end

--npc:ParticleOn("particles/quest_available.vpcf")
--npc:ParticleOff("particles/quest_available.vpcf")

--function QuestGiver:LightOff(npc_name)
--    local entity = SpawnSystem:GetUnique(npc_name)
--    if not entity then return end
--    entity:ParticleOff(questParticleName)
--end

--function QuestGiver:OnQuestDialogEvent(event)
--    --local QuestID = '1001'
--    
--    local choice = event.result
--    if choice == 1 then
--        Debug('QuestGiver', 'Quest accepted.')
--        -- TODO: Destroy just for that character.
--        QuestGiver:LightOff()
--        
--        -- Can't trust the client, so we have to remember what's open.
--        local player = PlayerResource:GetPlayer(event.PlayerID)
--        local QuestID = player.currentDialogForQuestID
--        QuestService:OnQuestStart(QuestID, event.PlayerID)
--    end
--end
--
--if not QuestGiver.initialized then
--    QuestGiver.initialized = true
--    QuestGiver:Init()
--end

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