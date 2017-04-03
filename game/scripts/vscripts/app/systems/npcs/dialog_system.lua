---
-- @type DialogSystem
DialogSystem = DialogSystem or class({})

function DialogSystem:Activate()
    CustomGameEventManager:RegisterListener('questgiver_dialog_event', Dynamic_Wrap(DialogSystem, 'OnQuestDialogEvent', QuestGiver))
end

--print(PlayerResource:IsValidPlayerID(0))
--local client = PlayerResource:GetPlayer(0)
--local caster = PlayerResource:GetSelectedHeroEntity(0)
--EmitSoundOnClient('Hero_Phoenix.IcarusDive.Stop', client)
-- EmitSoundOn('beastmaster_beas_rare_02', caster)


function DialogSystem:StartDialog(character, npc)
    local handled = false

    -- Create a special NPC handler class defined in the spawn/unit definition.
    -- beastmaster_beas_rare_02
    if npc.spawn_name == 'npc_quest_start' then
        if npc.first_interaction == nil then
            Debug('DialogSystem', 'First interaction beastmaster.')
            Sounds:EmitSoundOnClient(character:GetPlayerOwnerID(), 'beastmaster_beas_rare_02')
            -- EmitSoundOnClient('beastmaster_beas_rare_02', character:GetPlayerOwner())
            npc.first_interaction = false
        end
    end

    -- Check if character has quest to turn in.
    handled = self:CheckTurnIn(character, npc)

    if not handled then
        handled = self:CheckQuestAvailable(character, npc)
    end

    return handled
end

function DialogSystem:CheckTurnIn(character, npc)
    local quest = QuestService:FindTurnIn(character, npc)
    if not quest then return false end

    -- Debug('DialogSystem', inspect(quest))
    local player = character:GetPlayerOwner()
    player.currentDialogQuest = quest
    local data = quest:GetEndData();
    data.panelType = 'quest_complete'
    CustomGameEventManager:Send_ServerToPlayer(player, 'dialog_start', data)

    return true
end

function DialogSystem:CheckQuestAvailable(character, npc)
    local quest = QuestService:GetQuestForNpc(character, npc)
    if not quest then Debug('DialogSystem', 'No quest to present') return false end

    -- Can't trust the client, so we have to remember what's open.
    local player = character:GetPlayerOwner()
    player.currentDialogQuest = quest

    local data = quest:GetStartData();
    data.panelType = 'quest_start'
    CustomGameEventManager:Send_ServerToPlayer(player, 'dialog_start', data)

    return true
end

function DialogSystem:OnQuestDialogEvent(event)
    local choice = event.result
    if choice == 1 then
        Debug('DialogSystem', 'Quest accepted.')
        -- Can't trust the client, so we have to remember what's open.
        local player = PlayerResource:GetPlayer(event.PlayerID)
        local quest = player.currentDialogQuest
        if quest:IsComplete() then
            quest:Complete()
            QuestService:OnQuestComplete(quest)
        else
            --local player = PlayerResource:GetPlayer(event.PlayerID)
            quest:Accept()
            QuestService:OnQuestStart(quest)
        end
    end
end

if not DialogSystem.initialized then
    DialogSystem.initialized = true
    Event:Listen('Activate', Dynamic_Wrap(DialogSystem, 'Activate'), DialogSystem)
end
