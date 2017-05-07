---
-- @type DialogSystem
DialogSystem = DialogSystem or class({})

function DialogSystem:Activate()
    CustomGameEventManager:RegisterListener('dialog_event', Dynamic_Wrap(DialogSystem, 'OnDialogEvent', DialogSystem))
    Filters:OnOrderFilter(Dynamic_Wrap(DialogSystem, 'OrderFilter'), DialogSystem)
end

-- Close active dialog if exists.
function DialogSystem:OrderFilter(event, order)
    local hero = EntIndexToHScript(order.units['0'])
    local player = hero:GetPlayerOwner()
    if player and player.currentDialog then
        CustomGameEventManager:Send_ServerToPlayer(player, 'dialog_close', {})
        player.currentDialog = nil
    end
end

function DialogSystem:StartTeleportDialog(hero, target)
    -- Can't trust the client, so we have to remember what's open.
    local player = hero:GetPlayerOwner()
    player.currentDialogTeleporter = target
    player.currentDialog = 'Teleport'

    -- Unlock if not unlocked
    local alreadyUnlocked = hero.unlockedTeleports[target.spawn_name]
    if not alreadyUnlocked then
        hero.unlockedTeleports[target.spawn_name] = true
        Sounds:EmitSoundOnClient(hero:GetPlayerOwnerID(), 'Event.UnlockTransport')
        Http:ForceSave()
    end

    local allDestinations = {
        teleport_tower_town = 'zone_name_zone_town',
        teleport_tower_kobolds = 'zone_name_zone_kobolds',
        teleport_tower_webbed = 'zone_name_zone_webbed',
        teleport_tower_dark = 'zone_name_zone_dark',
        teleport_tower_druids = 'zone_name_zone_druids',
        teleport_tower_ice = 'zone_name_zone_ice',
    }
    local teleportOptions = {}
    local hasOptions = false
    for key,value in pairs(allDestinations) do
        if key ~= target.spawn_name and hero.unlockedTeleports[key] then
            hasOptions = true
            teleportOptions[key] = value
        end
    end

    --local data = quest:GetStartData();
    --data.panelType = 'quest_start'
    CustomGameEventManager:Send_ServerToPlayer(player, 'dialog_start', {
        spawn_name = target.spawn_name,
        unit_name = target:GetUnitName(),
        panelType = 'teleport',
        justUnlocked = not alreadyUnlocked,
        hasOptions = hasOptions,
        teleportOptions = teleportOptions,
    })
end

function DialogSystem:StartQuestDialog(hero, npc)
    local handled = false

    -- Create a special NPC handler class defined in the spawn/unit definition.
    -- beastmaster_beas_rare_02
    if npc.spawn_name == 'npc_quest_start' then
        if npc.first_interaction == nil then
            Debug('DialogSystem', 'First interaction beastmaster.')
            Sounds:EmitSoundOnClient(hero:GetPlayerOwnerID(), 'beastmaster_beas_rare_02')
            -- EmitSoundOnClient('beastmaster_beas_rare_02', character:GetPlayerOwner())
            npc.first_interaction = false
        end
    end

    -- Check if character has quest to turn in.
    handled = self:CheckTurnIn(hero, npc)

    if not handled then
        handled = self:CheckQuestAvailable(hero, npc)
    end

    return handled
end

function DialogSystem:CheckTurnIn(character, npc)
    local quest = QuestService:FindTurnIn(character, npc)
    if not quest then return false end

    -- Debug('DialogSystem', inspect(quest))
    local player = character:GetPlayerOwner()
    player.currentDialogQuest = quest
    player.currentDialog = 'Quest'

    local data = quest:GetEndData();
    data.panelType = 'quest_complete'
    CustomGameEventManager:Send_ServerToPlayer(player, 'dialog_start', data)

    return true
end

function DialogSystem:CheckQuestAvailable(hero, npc)
    local quest = QuestService:GetQuestForNpc(hero, npc)
    if not quest then Debug('DialogSystem', 'No quest to present') return false end

    -- Can't trust the client, so we have to remember what's open.
    local player = hero:GetPlayerOwner()
    player.currentDialogQuest = quest
    player.currentDialog = 'Quest'

    local data = quest:GetStartData();
    data.panelType = 'quest_start'
    CustomGameEventManager:Send_ServerToPlayer(player, 'dialog_start', data)

    return true
end

function DialogSystem:OnDialogEvent(event)
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if player.currentDialog then
        local callback = 'On'..player.currentDialog..'DialogEvent'
        -- We clear it out now, since the callback may set it again to chain quest dialogs.
        player.currentDialog = nil
        if DialogSystem[callback] then
            DialogSystem[callback](self, event)
        else
            Debug('DialogSystem', 'Missing Dialog Callback', player.currentDialog)
        end
    else
        Debug('DialogSystem', 'Player has no active dialog.')
    end
end

function DialogSystem:OnQuestDialogEvent(event)
    local choice = event.result
    if choice == 1 then
        Debug('DialogSystem', 'Quest accepted.')

        -- Can't trust the client, so we have to remember what's open.
        local player = PlayerResource:GetPlayer(event.PlayerID)
        local quest = player.currentDialogQuest
        -- Which NPC to check depends on whether we're finishing or starting.
        local npc
        if quest:IsComplete() then
            EmitSoundOnClient('ui.treasure_03', player)
            quest:Complete()
            QuestService:OnQuestComplete(quest)
            npc = quest:GetEndNpc()
        else
            EmitSoundOnClient('ui.trophy_new', player)
            quest:Accept()
            QuestService:OnQuestStart(quest)
            npc = quest:GetStartNpc()
        end

        -- Check if there is another quest action.
        DialogSystem:StartQuestDialog(player:GetAssignedHero(), npc)
    end
end

function DialogSystem:OnTeleportDialogEvent(event)
    local choice = event.result

    if choice == 1 then
        Debug('DialogSystem', 'Teleport accepted.')

        -- Can't trust the client, so we have to remember what's open.
        local player = PlayerResource:GetPlayer(event.PlayerID)
        local target = player.currentDialogTeleporter
        local hero = player:GetAssignedHero()
        local destination = event.destination

        -- Ensure they are allowed to go there.
        if not hero.unlockedTeleports[destination] then
            -- Consider logging potential cheat?
            return
        end

        -- Ensure they have the monies

        -- Go there!
        hero:AddNewModifier(hero, nil, 'character_teleporting', {
            from = target.spawn_name,
            to   = destination
        })

        -- Take Monies!!

        --if target.spawn_name == 'teleport_tower_town' then
        --    hero:AddNewModifier(hero, nil, 'character_teleporting', {
        --        from = 'teleport_tower_town',
        --        to = 'teleport_tower_kobolds'
        --    })
        --elseif target.spawn_name == 'teleport_tower_kobolds' then
        --    hero:AddNewModifier(hero, nil, 'character_teleporting', {
        --        from = 'teleport_tower_kobolds',
        --        to = 'teleport_tower_webbed'
        --    })
        --elseif target.spawn_name == 'teleport_tower_webbed' then
        --    hero:AddNewModifier(hero, nil, 'character_teleporting', {
        --        from = 'teleport_tower_webbed',
        --        to = 'teleport_tower_dark'
        --    })
        --elseif target.spawn_name == 'teleport_tower_dark' then
        --    hero:AddNewModifier(hero, nil, 'character_teleporting', {
        --        from = 'teleport_tower_dark',
        --        to = 'teleport_tower_town'
        --    })
        --elseif target.spawn_name == 'teleport_tower_ice' then
        --    hero:AddNewModifier(hero, nil, 'character_teleporting', {
        --        from = 'teleport_tower_ice',
        --        to = 'teleport_tower_town'
        --    })
        --else
        --    print('waaa')
        --end
    end
end

if not DialogSystem.initialized then
    DialogSystem.initialized = true
    Event:Listen('Activate', Dynamic_Wrap(DialogSystem, 'Activate'), DialogSystem)
end
