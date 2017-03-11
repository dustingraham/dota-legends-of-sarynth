---
-- @type DialogSystem
DialogSystem = DialogSystem or class({})

function DialogSystem:Activate()
    CustomGameEventManager:RegisterListener('questgiver_dialog_event', Dynamic_Wrap(DialogSystem, 'OnQuestDialogEvent', QuestGiver))
end

function DialogSystem:StartDialog(character, npc)
    local quest = QuestService:GetQuestForNpc(character, npc)
    if not quest then Debug('DialogSystem', 'No quest to present') return end
    
    -- Can't trust the client, so we have to remember what's open.
    local player = character:GetPlayerOwner()
    player.currentDialogQuest = quest
    
    local data = quest:GetStartData();
    data.panelType = 'quest'
    CustomGameEventManager:Send_ServerToPlayer(player, 'dialog_start', data)
end

function DialogSystem:OnQuestDialogEvent(event)
    local choice = event.result
    if choice == 1 then
        Debug('DialogSystem', 'Quest accepted.')
        -- Can't trust the client, so we have to remember what's open.
        local player = PlayerResource:GetPlayer(event.PlayerID)
        local quest = player.currentDialogQuest
        quest:Accept()
        
        --local player = PlayerResource:GetPlayer(event.PlayerID)
        QuestService:OnQuestStart(quest)
    end
end

if not DialogSystem.initialized then
    DialogSystem.initialized = true
    Event:Listen('Activate', Dynamic_Wrap(DialogSystem, 'Activate'), DialogSystem)
end
