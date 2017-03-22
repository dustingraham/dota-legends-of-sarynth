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
    Notifications:Top(pid, {
        text = "#town_gate_trigger_soon",
        duration = 5,
        style = { color = "#ffcc00" }
    })
    Sounds:EmitSoundOnClient(pid, 'jboberg_01.stinger.radiant_lose')
end
function SoonTownGateTrigger(trigger)
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
    print('Boss Start Touch: ', pid)
    local relay = Entities:FindByName(nil, 'start_area_barricade_relay_on')
    relay:Trigger()
    MoveBlockers(219.125)
    -- https://github.com/SteamDatabase/GameTracking-Dota2/blob/c6a10d9fc4eae2aff810c9893377d675ddf3ffc4/game/dota/pak01_dir/soundevents/music/jboberg_01/soundevents_stingers.vsndevts
    Sounds:EmitSoundOnClient(pid, 'jboberg_01.music.battle_01')
end
function StartBossAreaEndTouch(trigger)
    local pid = trigger.activator:GetPlayerOwnerID()
    print('Boss End Touch: ', pid)
    local relay = Entities:FindByName(nil, 'start_area_barricade_relay_off')
    relay:Trigger()
    MoveBlockers(-219.125)
    Sounds:EmitSoundOnClient(pid, 'jboberg_01.music.battle_01_end')
end
function MoveBlockers(distance)
    local blockers = Entities:FindAllByName('start_area_barricade_wall')
    -- 40 intervals
    local d = distance / 40
    local i = 0
    local total = 0
    Timers:CreateTimer(function()
        for _,blocker in pairs(blockers) do
            blocker:SetAbsOrigin(blocker:GetAbsOrigin()+Vector(0,0,d))
        end
        total = total + d
        i = i + 1
        if i > 40 then
            print(total)
            return nil
        end
        return 0.03
    end)
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