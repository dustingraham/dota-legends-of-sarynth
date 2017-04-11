---
--@type QuestService
QuestService = QuestService or class({}, {
    playerQuests = {},
    playerCompleted = {},
    questParticleName = "particles/quest_indicator.vpcf",
})

function QuestService:Activate()
    ListenToGameEvent('entity_killed', Dynamic_Wrap(QuestService, 'OnEntityKilled'), QuestService)
    Event:Listen('HeroPick', Dynamic_Wrap(QuestService, 'OnHeroPick'), QuestService)
    Event:Listen('HeroLevelUp', Dynamic_Wrap(QuestService, 'OnHeroLevelUp'), QuestService)
end

function QuestService:OnHeroPick(e, event)
    -- Load Quest Data
    local key = 'player_'..event.PlayerID..'_quests'
    local quests = event.player:GetPriorQuests()
    if quests then
        QuestService.playerCompleted[key] = quests.completed
        for _,questProgress in pairs(quests.progress) do
            -- Generate Quest Start
            local quest = QuestService:MakeQuestForPlayer(questProgress.id, event.PlayerID)
            quest:Accept()
            -- Apply Progress
            for _,objective in pairs(questProgress.objectives) do
                if quest.objectives[objective.oid].action == 'kill' then
                    quest.objectives[objective.oid].current = objective.current
                    if quest.objectives[objective.oid].required ~= objective.required then
                        -- Make note that they don't match. Not much we can do.
                        Debug(
                            'QuestService',
                            'Saved required count does not match.',
                            quest.objectives[objective.oid].required,
                            objective.required
                        )
                    end
                end
                --if quest.objectives[objective.oid].action == 'report' then
                --    if not quest.objectives[objective.oid].reported then
                --
                --    end
                --end
            end
            -- Start it
            QuestService:OnQuestStart(quest)
        end
    end

    -- Initialize/merge in test quests.
    if TEST_QUESTS_COMPLETE then
        if not QuestService.playerCompleted[key] then
            QuestService.playerCompleted[key] = TEST_QUESTS_COMPLETE
        else
            for id,quest in pairs(TEST_QUESTS_COMPLETE) do
                QuestService.playerCompleted[key][id] = quest
            end
        end
    end

    -- Initialize Quests
    QuestService:CheckForQuestsAvailable(event.PlayerID)
end

-- Check for any potentially new quests after level up.
function QuestService:OnHeroLevelUp(e, event)
    QuestService:CheckForQuestsAvailable(event.hero:GetPlayerOwnerID())
end

function QuestService:OnQuestStart(quest)
    -- print('QSPID', quest.PlayerID)
    -- print('QSQID', quest.id)
    local key = 'player_'..quest.PlayerID..'_quests'
    if QuestService.playerQuests[key] == nil then
        QuestService.playerQuests[key] = {}
    end
    QuestService.playerQuests[key][quest.id] = quest

    PlayerTables:SetTableValue(key, quest.id, quest:GetData())

    Debug('QuestService', 'Quest Started: ', quest:GetName())

    local hero = PlayerResource:GetSelectedHeroEntity(quest.PlayerID)
    Event:Trigger('HeroStartedQuest', {
        hero = hero,
        quest = quest,
    })

    -- In case the same npc has another quest
    QuestService:CheckForQuestsAvailable(quest.PlayerID)
end

function QuestService:SendQuestUpdate(quest)
    local key = 'player_'..quest.PlayerID..'_quests'
    PlayerTables:SetTableValue(key, quest.id, quest:GetData())
end

function QuestService:CheckIfCompleted(PlayerID, QuestID)
    local key = 'player_'..PlayerID..'_quests'

    if QuestService.playerCompleted[key] == nil then return false end
    for id,name in pairs(QuestService.playerCompleted[key]) do
        if QuestID == id or QuestID == name then return true end
    end

    return false
end

function QuestService:OnQuestComplete(quest)
    -- Reward and delete quest.
    -- Track in history of some sort.
    local key = 'player_'..quest.PlayerID..'_quests'
    PlayerTables:DeleteTableKey(key, quest.id)

    QuestService.playerQuests[key][quest.id] = nil

    if QuestService.playerCompleted[key] == nil then
        QuestService.playerCompleted[key] = {}
    end
    QuestService.playerCompleted[key][quest.id] = quest:GetName()

    Debug('QuestService', 'Quest Completed: ',quest:GetName())
    Debug('QuestService', 'Completion Table: ', inspect(QuestService.playerCompleted))

    local hero = PlayerResource:GetSelectedHeroEntity(quest.PlayerID)

    Event:Trigger('HeroCompletedQuest', {
        hero = hero,
        quest = quest,
    })

    -- Give Reward
    quest:ApplyReward(hero)

    -- Tmp
    if quest.id == '1012' then
        Notifications:Top(quest.PlayerID, {
            text = "#alpha_release_the_end",
            duration = 30,
            style = { color = "#b21d00" }
        })
        Notifications:Top(quest.PlayerID, {
            text = "#alpha_release_the_end2",
            duration = 15,
            style = { color = "#cccccc" }
        })
    end

    -- Check if any quests open up now.
    QuestService:CheckForQuestsAvailable(quest.PlayerID)
end

---
-- Deprecating
function QuestService:OnOpenQuestDialog(QuestID, PlayerID, questData, action)
    if not questData then Debug('QuestService', 'No Quest Available') return end

    -- Lookup the quest
    local quest = QuestService:GetPlayerQuest(PlayerID, QuestID)

    if quest == nil then
        -- Attempting to start quest, check start entity.
        if questData.start_entity ~= action.target:GetUnitName() then return end

        -- If we have no records of it, prompt player
        local player = PlayerResource:GetPlayer(PlayerID)
        -- Can't trust the client, so we have to remember what's open.
        player.currentDialogForQuestID = QuestID
        CustomGameEventManager:Send_ServerToPlayer(player, 'questgiver_open', questData)
    elseif quest:IsComplete() then
        -- Attempting to end quest, check start entity.
        if quest.end_entity ~= action.target:GetUnitName() then return end

        -- They completed it!
        QuestService:OnQuestComplete(QuestID, PlayerID)
    else
        -- In progress....
        Debug('QuestService', 'Quest is in progress...')
    end
end

function QuestService:FindTurnIn(character, npc)
    local key = 'player_'..character:GetPlayerOwnerID()..'_quests'
    if QuestService.playerQuests[key] == nil then return nil end
    for _,quest in pairs(QuestService.playerQuests[key]) do
        if npc == quest:GetEndNpc() then
            if quest:IsComplete() then
                return quest
            end
        end
    end
    return nil
end

function QuestService:GetPlayerQuest(PlayerID, QuestID)
    local key = 'player_'..PlayerID..'_quests'
    if QuestService.playerQuests[key] == nil then return nil end

    -- Search Current Quests
    for id,quest in pairs(QuestService.playerQuests[key]) do
        if QuestID == id or QuestID == quest.name then return quest end
    end

    -- Not Found
    return nil
end

function QuestService:OnEntityKilled(event)
    if not event.entindex_attacker then return end
    local attacker = EntIndexToHScript(event.entindex_attacker);
    if not attacker:IsHero() then return end

    local killed = EntIndexToHScript(event.entindex_killed);
    -- DeepPrintTable(killed)
    local key = 'player_'..attacker:GetPlayerID()..'_quests'
    local quests = QuestService.playerQuests[key]
    if quests == nil then return end

    local killed_name = killed:GetUnitName();
    Debug('QuestService', attacker:GetName()..' killed '..killed_name)
    for _,quest in pairs(quests) do
        quest:OnEntityKilled(killed_name)
    end
end

function QuestService:OnEntityInteract(hero, npc)
    local key = 'player_'..hero:GetPlayerOwnerID()..'_quests'
    local quests = QuestService.playerQuests[key]
    if quests == nil then return end

    local name = npc:GetUnitName();
    Debug('QuestService', hero:GetName()..' interacted with '..name)
    for _,quest in pairs(quests) do
        quest:OnEntityInteract(name)
    end
end

-- Deprecating
--function QuestService:OnRightClickQuestGiver(action)
--    --local targetEntity = action.target
--    local PlayerID = action.PlayerID
--
--    -- HAC Only one quest at a time right now....
--    local QuestID = action.target.quest.id
--
--    -- .questgiver:OpenQuestDialog(action.PlayerID)
--    -- local QuestID = QuestGiver.QuestID
--    QuestService:OnOpenQuestDialog(QuestID, PlayerID, QuestGiver.quest, action)
--end


local function CheckRequirements(completedQuests, inProgressQuests, hero, quest)
    if completedQuests[quest.id] then
        Debug('QuestService', '['..quest.name..'] Already Completed.')
        return false
    end
    if inProgressQuests[quest.id] then
        Debug('QuestService', '['..quest.name..'] Already in progress.')
        return false
    end

    if not quest.requirements then return true end

    local reqs = quest.requirements
    if reqs.level and hero:GetLevel() < reqs.level then
        Debug('QuestService', '['..quest.name..'] Insufficient level.')
        return false
    end
    if reqs.quest then
        for _,preQuest in pairs(Split(reqs.quest)) do
            local hasCompleted = false
            for _,completedQuest in pairs(completedQuests) do
                if completedQuest == preQuest then
                    hasCompleted = true
                    break
                end
            end
            if hasCompleted == false then
                Debug('QuestService', '['..quest.name..'] Not yet completed pre-quest: '..preQuest)
                return false
            end
        end
    end

    -- Passes all checks.
    return true
end

function QuestService:CheckForQuestsAvailable(PlayerID)
    Debug('QuestService', 'Check For Quest Available')
    local key = 'player_'..PlayerID..'_quests'
    local completedQuests = QuestService.playerCompleted[key] or {}
    local inProgressQuests = QuestService.playerQuests[key] or {}

    Debug('QuestService', inspect(completedQuests))

    local hero = PlayerResource:GetSelectedHeroEntity(PlayerID)

    for _,quest in pairs(QuestRepository.data) do
        if CheckRequirements(completedQuests, inProgressQuests, hero, quest) then
            Debug('QuestService', '['..quest.name..'] Available!')
            local npc = SpawnSystem:GetUnique(quest.start_entity)
            if npc then npc:ParticleOnForPlayer(QuestService.questParticleName, PlayerID) end
        end
    end
end

function QuestService:GetQuestForNpc(character, npc)
    Debug('QuestService', 'GetQuestForNpc')
    local key = 'player_'..character:GetPlayerOwnerID()..'_quests'
    local completedQuests = QuestService.playerCompleted[key] or {}
    local inProgressQuests = QuestService.playerQuests[key] or {}

    --Debug('QuestService', 'completed', inspect(completedQuests))
    --Debug('QuestService', 'npc', inspect(npc))

    local npcName = npc.spawn_name
    Debug('QuestService', 'Search for: ', npcName)

    for _,quest in pairs(QuestRepository.data) do
        if quest.start_entity == npcName then
            if CheckRequirements(completedQuests, inProgressQuests, character, quest) then
                Debug('QuestService', '['..quest.name..'] Available!')
                return Quest(character:GetPlayerOwnerID(), quest)
            end
        end
    end
end

function QuestService:MakeQuestForPlayer(questKey, PlayerID)
    return Quest(
    PlayerID,
    QuestRepository:GetQuest(questKey)
    )
end

-- QuestService:CheckForQuestsAvailable(0)


if not QuestService.initialized then
    QuestService.initialized = true
    Event:Listen('Activate', Dynamic_Wrap(QuestService, 'Activate'), QuestService)
end



--[[
    Eventually

    Track quests as numeric representations to minimize data transmission.
    If quest is not started, or has been abandoned, there will be no record.
    Thus in progress and completed values: 0, 1
    {
        QuestID
        QuestState [0, 1] In Progress, Completed
        CompletionCount
        ObjectiveCounts
        {
            1, 2, 3 Matching the objectives defined in the quest.
        }
        QuestVersion ?? If quest is modified, reset objective counts?
    }

]]

-- Concept:
-- CustomGameEventManager:RegisterListener( "LevelUpButtonPressed", function(...) return self:OnLevelUpButtonPressed( ... ) end )
-- But do we really need it, perhaps this is just a generic thing. Or maybe we make our own event wrapper shuttle thing.

