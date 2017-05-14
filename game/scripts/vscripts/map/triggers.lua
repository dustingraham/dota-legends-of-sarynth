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

function DruidsBuildingStartTouch(trigger)
    local roof = Entities:FindByName(nil, 'druids_building_roof')
    roof:SetAbsOrigin(roof:GetAbsOrigin() - Vector(0,0,512))
    local pos = Entities:FindByName(nil, 'zone_druids_boss_center'):GetAbsOrigin()
    AddFOWViewer(trigger.activator:GetTeamNumber(), pos, 1024, 600, true)
end

function DruidsBuildingEndTouch(trigger)
    local roof = Entities:FindByName(nil, 'druids_building_roof')
    roof:SetAbsOrigin(roof:GetAbsOrigin() + Vector(0,0,512))
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
    local hero = trigger.activator
    local zone = trigger.caller:GetName()

    -- We don't care about zone in of the wisp
    if hero:GetUnitName() == DUMMY_HERO then return end

    if hero.currentZone ~= zone then
        Debug('Triggers', 'PlayerID ', hero:GetPlayerOwnerID(), 'zoning into', zone)
        Event:Trigger('ZoneIn', {
            hero = hero,
            zone = zone
        })
        hero.currentZone = zone
    end
end
