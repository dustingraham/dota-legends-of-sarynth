---
-- Scripts called by map entities.
--

---
-- Introductions - Area 2 Gate Demolish
--
function Area2_OnStartTouch(trigger)
    local hero = trigger.activator
    Debug('Triggers', 'Area2_OnStartTouch', thisEntity:GetName(), hero:GetUnitName())

    -- Check Quest Completed
    if QuestService:CheckIfCompleted(hero:GetPlayerOwnerID(), 'intro_worg_2') then
        Entities:FindByName(nil, 'area_2_relay'):Trigger()
        thisEntity:Destroy()
        Debug('Triggers', 'Area 2 Gate Opened')
    end
end

function IceBarricadeTrigger(trigger)
    local relay = Entities:FindByName(nil, 'ice_barricade_1_relay')
    relay:Trigger()
    ScreenShake(relay:GetAbsOrigin(), 3, 100, 1.25, 4500, 0, true)
    thisEntity:Destroy()
    Debug('Triggers', 'Ice Barricade 1 Opened')
end

function TownGateTrigger(trigger)
    local pid = trigger.activator:GetPlayerOwnerID()
    local quest = QuestService:GetPlayerQuest(pid, 'start_area_report_to_town')
    if quest or QuestService:CheckIfCompleted(pid, 'start_area_report_to_town') then
        Entities:FindByName(nil, 'town_entrance_relay'):Trigger()
        thisEntity:Destroy()
    else
        -- print(inspect(trigger))
        Notifications:Top(pid, {
            text = "#town_gate_trigger_fail",
            duration = 5,
            style = { color = "#ffcc00" }
        })
        Debug('Triggers', 'Player '..pid..' triggered town gate closed message.')
    end
end

function DungeonAreaStartTouch(trigger)
    trigger.activator:FindModifierByName('character_vision'):ReduceVision()
end

function DungeonAreaEndTouch(trigger)
    trigger.activator:FindModifierByName('character_vision'):RestoreVision()
end

function StartBossAreaStartTouch(trigger)
    local pid = trigger.activator:GetPlayerOwnerID()
    -- print('Boss Start Touch: ', pid)

    -- https://github.com/SteamDatabase/GameTracking-Dota2/blob/c6a10d9fc4eae2aff810c9893377d675ddf3ffc4/game/dota/pak01_dir/soundevents/music/jboberg_01/soundevents_stingers.vsndevts
    Sounds:EmitSoundOnClient(pid, 'jboberg_01.music.battle_02')

    -- Also call the standard trigger.
    ZoneIn(trigger)
end
function StartBossAreaEndTouch(trigger)
    local pid = trigger.activator:GetPlayerOwnerID()
    -- print('Boss End Touch: ', pid)

    Sounds:EmitSoundOnClient(pid, 'jboberg_01.music.battle_02_end')
    -- Sounds:EmitSoundOnClient(pid, 'jboberg_01.music.ui_main')
end

--function StartAreaBarricadeWallUp(trigger)
--    print('Wall Up Trigger')
--    -- 219.125
--    DeepPrintTable(trigger)
--end
--function StartAreaBarricadeWallDown(trigger)
--    print('Wall Down Trigger')
--    -- 0.00
--    DeepPrintTable(trigger)
--end

function ZoneIn(trigger)
    Debug('TriggersVerbose', trigger.activator:GetPlayerOwnerID(), 'zoning into', trigger.caller:GetName())
    CharacterService:SetZone(trigger.activator, trigger.caller:GetName())
end
