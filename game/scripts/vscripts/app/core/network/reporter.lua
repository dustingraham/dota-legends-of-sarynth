---
--@type Reporter
Reporter = Reporter or class({})

---
--@function [parent=#Reporter] constructor
--@param self
function Reporter:Activate(params)
    if IsInToolsMode() then
        Debug('Reporter', 'ToolsMode: Logging to localhost.')
    elseif GameRules:IsCheatMode() then
        Debug('Reporter', 'Not Logging Cheat Mode')
        return
    end

    Event:Listen('HeroPick', Dynamic_Wrap(Reporter, 'OnHeroPick'), Reporter)
    Event:Listen('HeroLevelUp', Dynamic_Wrap(Reporter, 'OnHeroLevelUp'), Reporter)
    Event:Listen('HeroDeath', Dynamic_Wrap(Reporter, 'OnHeroDeath'), Reporter)

    Event:Listen('InventoryAdd', Dynamic_Wrap(Reporter, 'OnInventoryAdd'), Reporter)
    Event:Listen('InventoryRemove', Dynamic_Wrap(Reporter, 'OnInventoryRemove'), Reporter)

    Event:Listen('HeroStartedQuest', Dynamic_Wrap(Reporter, 'OnHeroStartedQuest'), Reporter)
    Event:Listen('HeroCompletedQuest', Dynamic_Wrap(Reporter, 'OnHeroCompletedQuest'), Reporter)
    Event:Listen('HeroKilledCreature', Dynamic_Wrap(Reporter, 'OnHeroKilledCreature'), Reporter)

    Debug('Reporter', 'Initialized')
end
Event:BindActivate(Reporter)

--[[
     Events
     - Player Level Up (+Save)
     - Player Quest (Start, Objective, Complete, TurnIn)
     - Player Kill Mob (Queue every 30 sec?)
     - Player Adds Item to Inventory
     - Player Removes Item from Inventory
]]

function Reporter:CreateReport(params)
    if not IsInToolsMode() and GameRules:IsCheatMode() then return end
    if IsInToolsMode() then
        Debug('Reporter', 'Reporting to localhost.')
    end

    local PlayerID = params.player_id
    local version = 1

    TableMerge(params, {
        match_id = Boot.MatchID,
        system_time = GetSystemDate()..' '..GetSystemTime(),
        game_time = math.ceil(GameRules:GetGameTime()),
        map = GetMapName(),
        version = version,
        player_id_64 = tostring(PlayerResource:GetSteamID(PlayerID)),
    })

    Debug('ReporterVerbose', inspect(params))

    Http:SendReport(params)
    -- local player = PlayerResource:GetPlayer( params.player_id_const )
    -- local hero = PlayerResource:GetSelectedHeroEntity(params.player_id_const)

end

function Reporter:PullCharacterReport(PlayerID)
    Debug('ReporterVerbose', 'Pulling character report.')
    local player = PlayerService:GetPlayer(PlayerID)
    return {
        event_name = 'character_status',
        player_id_64 = tostring(PlayerResource:GetSteamID(PlayerID)),
        slot_id = player:GetSlotId(),
        data = player:GetSaveData(),
    }
end

REPORTER_REPORT = {
    hero_pick = true,
    hero_level_up = true,
}

function Reporter:OnHeroPick(e, event)
    if not REPORTER_REPORT['hero_pick'] then return end

    Debug('Reporter', 'OnHeroPick')
    Debug('Reporter', 'Hero: ', event.hero:GetName())
    self:CreateReport({
        event_name = 'hero_pick',
        player_id = event.hero:GetPlayerOwnerID(),
        hero_name = event.hero:GetName(),
    })
end

function Reporter:OnHeroLevelUp(e, event)
    Debug('Reporter', 'OnHeroLevelUp')
    Debug('Reporter', 'Hero: ', event.hero:GetName())
    Debug('Reporter', 'Level: ', event.hero:GetLevel())
    self:CreateReport({
        event_name = 'hero_level_up',
        player_id = event.hero:GetPlayerOwnerID(),
        hero_name = event.hero:GetName(),
        level = event.hero:GetLevel(),
    })
end

function Reporter:OnHeroDeath(e, event)
    Debug('Reporter', 'OnHeroDeath')
    Debug('Reporter', 'Hero: ', event.hero:GetName())

    local killer = 'unknown_nil_entindex_attacker'
    if event.killer then
        killer = event.killer:GetUnitName()
    end

    Debug('Reporter', 'Killer: ', killer)

    self:CreateReport({
        event_name = 'hero_death',
        player_id = event.hero:GetPlayerOwnerID(),
        hero_name = event.hero:GetName(),
        killer_name = killer,
    })
end

-- Pick up from world, buyback, or buy
function Reporter:OnInventoryAdd(e, event)
    -- Don't record items created on load
    if event.item.initialCreate then
        event.item.initialCreate = nil
        return
    end

    Debug('Reporter', 'OnInventoryAdd')
    Debug('Reporter', 'Hero: ', event.hero:GetName())
    Debug('Reporter', 'Item: ', event.item:GetAbilityName())
    self:CreateReport({
        event_name = 'hero_inventory_add',
        player_id = event.hero:GetPlayerOwnerID(),
        hero_name = event.hero:GetName(),
        item_name = event.item:GetAbilityName(),
    })
end

-- Drop to world or sell.
function Reporter:OnInventoryRemove(e, event)
    Debug('Reporter', 'OnInventoryRemove')
    Debug('Reporter', 'Hero: ', event.hero:GetName())
    Debug('Reporter', 'Item: ', event.item:GetAbilityName())
    self:CreateReport({
        event_name = 'hero_inventory_remove',
        player_id = event.hero:GetPlayerOwnerID(),
        hero_name = event.hero:GetName(),
        item_name = event.item:GetAbilityName(),
    })
end

function Reporter:OnHeroStartedQuest(e, event)
    Debug('Reporter', 'OnHeroStartedQuest')
    Debug('Reporter', 'Hero: ', event.hero:GetName())
    Debug('Reporter', 'Quest: ', event.quest:GetName())
    self:CreateReport({
        event_name = 'hero_started_quest',
        player_id = event.hero:GetPlayerOwnerID(),
        hero_name = event.hero:GetName(),
        quest_name = event.quest:GetName(),
    })
end

function Reporter:OnHeroCompletedQuest(e, event)
    Debug('Reporter', 'OnHeroCompletedQuest')
    Debug('Reporter', 'Hero: ', event.hero:GetName())
    Debug('Reporter', 'Quest: ', event.quest:GetName())
    self:CreateReport({
        event_name = 'hero_completed_quest',
        player_id = event.hero:GetPlayerOwnerID(),
        hero_name = event.hero:GetName(),
        quest_name = event.quest:GetName(),
    })
end

function Reporter:OnHeroKilledCreature(e, event)
    Debug('Reporter', 'OnHeroKilledCreature')
    Debug('Reporter', 'Hero: ', event.hero:GetName())
    Debug('Reporter', 'Creature: ', event.creature:GetUnitName())
    self:CreateReport({
        event_name = 'hero_killed_creature',
        player_id = event.hero:GetPlayerOwnerID(),
        hero_name = event.hero:GetName(),
        creature_name = event.creature:GetUnitName(),
    })
end
