---
--@type Boot
Boot = Boot or {}

DUMMY_HERO = 'npc_dota_hero_wisp'

function Boot:Test()
    _G.GameItems = LoadKeyValues("scripts/items/items_game.txt")

    local heroes = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
    local units = LoadKeyValues("scripts/npc/npc_units_custom.txt")
    local cosmeticsParticles = {}

    --for name,unit in pairs(units) do
    --    PrecacheUnitByNameSync(name, context)
    --    print(name)
    --    do return end
    --end
    for name,hero in pairs(heroes) do
        print(name)
        DeepPrintTable(hero)
        do return end
    end

    for _,data in pairs(GameItems.items) do
        print(_)
        DeepPrintTable(data)
        do return end
    end
    DeepPrintTable(units)
end

-- Boot:Test()

function Boot:Activate()
    Debug('Boot', 'Activate')

    ListenToGameEvent('player_connect_full', Dynamic_Wrap(Boot, 'OnConnectFull'), self)
    ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(Boot, 'OnGameRulesStateChange'), self)

    Boot:InitGameRules()
    Boot:InitGameModeEntity()

    Event:Trigger('Activate')
end

function Boot:InitGameRules()
    -- Change random seed (For some reason, lua can't do this in a single line...)
    -- Tested this with 132517192808 which is above the theoretical max value.
    -- Theoretical max is 1231yy235959 where yy is the year. So this seed
    -- should be an ever changing safe value. Note, it is not ever increasing,
    -- since it will jump backwards on the change of the year.
    local dateTimeString = string.gsub(string.gsub(GetSystemDate()..GetSystemTime(), '%W', ''), '^0+','')
    math.randomseed(tonumber(dateTimeString))

    -- We will store this value to use as the match id.
    -- Actual value is set in the game rules state change below if not in tools mode.
    Boot.MatchID = dateTimeString

    -- Setup fast load to get to our custom start screen
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 3)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
    -- Essential to set team for each player.
    PlayerResource:SetCustomTeamAssignment(0, DOTA_TEAM_GOODGUYS)
    PlayerResource:SetCustomTeamAssignment(1, DOTA_TEAM_GOODGUYS)
    PlayerResource:SetCustomTeamAssignment(2, DOTA_TEAM_GOODGUYS)
    GameRules:SetCustomGameSetupTimeout(0)
    GameRules:SetStrategyTime(0)
    GameRules:SetShowcaseTime(0)
    GameRules:SetPreGameTime(0)

    GameRules:SetCustomGameSetupAutoLaunchDelay(0)
    GameRules:LockCustomGameSetupTeamAssignment(true)
    GameRules:EnableCustomGameSetupAutoLaunch(true)

    GameRules:SetPostGameTime(15)

    -- Trees
    GameRules:SetTreeRegrowTime(30)

    GameRules:SetGoldPerTick(0)
    GameRules:SetStartingGold(100)

    -- For reference
    -- GameRules:SetHeroSelectionTime(0)
    -- GameRules:SetCustomGameEndDelay(-1)
    -- GameRules:SetHeroRespawnEnabled(false)
    -- GameRules:SetUseUniversalShopMode(true)
    --GameRules:SetSameHeroSelectionEnabled(true)
    -- GameRules:SetUseCustomHeroXPValues(false)
    -- GameRules:SetGoldTickTime(GOLD_TICK_TIME)
    -- GameRules:SetRuneSpawnTime(RUNE_SPAWN_TIME)
    -- GameRules:SetUseBaseGoldBountyOnHeroes(USE_STANDARD_HERO_GOLD_BOUNTY)
    -- GameRules:SetHeroMinimapIconScale( MINIMAP_ICON_SIZE )
    -- GameRules:SetCreepMinimapIconScale( MINIMAP_CREEP_ICON_SIZE )
    -- GameRules:SetRuneMinimapIconScale( MINIMAP_RUNE_ICON_SIZE )
    -- GameRules:SetFirstBloodActive( ENABLE_FIRST_BLOOD )
    -- GameRules:SetHideKillMessageHeaders( HIDE_KILL_BANNERS )
    -- GameRules:SetCustomVictoryMessageDuration( VICTORY_MESSAGE_DURATION )
    --
    -- SetTeamCustomHealthbarColor(DOTA_TEAM_GOODGUYS, 255, 0, 255)

    Debug('Boot', 'Configured GameRules')
end

function Boot:InitGameModeEntity()
    -- Only configure mode on the first full connect.
    local mode = GameRules:GetGameModeEntity()

    -- Hero
    mode:SetCustomGameForceHero(DUMMY_HERO)
    mode:SetBuybackEnabled(false)

    -- Bugged, neutral kills are fixed 26 seconds.
    mode:SetFixedRespawnTime(5)

    -- Environment
    mode:SetDaynightCycleDisabled(true)

    -- Functions want a boolean value.
    local enableFog = not TEST_DISABLE_FOG
    mode:SetFogOfWarDisabled(not enableFog)
    mode:SetUnseenFogOfWarEnabled(enableFog)

    -- Camera : -1 for default. (Default is about 1134)
    mode:SetCameraDistanceOverride(-1)

    -- UI/Items
    mode:SetStickyItemDisabled(true)
    mode:SetRecommendedItemsDisabled(true)

    -- Announcers
    mode:SetAnnouncerDisabled(true)
    mode:SetKillingSpreeAnnouncerDisabled(true)
    mode:SetGoldSoundDisabled(false)

    -- Levels
    local levels = CharacterService:GetExperienceLevelRequirements()
    mode:SetUseCustomHeroLevels(true)
    mode:SetCustomXPRequiredToReachNextLevel(levels)

    Debug('Boot', 'Configured GameModeEntity')
end

function Boot:OnConnectFull(event)
    Debug('Boot', 'OnConnectFull')
end

function Boot:OnGameRulesStateChange()
    Debug('Boot', 'State Change :',GameRules:State_Get())

    if GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        -- If we are in tools mode, there is no worry about a duplicate match from concurrent start time.
        if not IsInToolsMode() then
            -- If we are live, then Valve handles the match ID value.
            Boot.MatchID = tostring(GameRules:GetMatchID())
        end

        Event:Trigger('OnStateGameSetup')
    end

    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        Event:Trigger('OnStateInGame')
    end
end

function Boot:DebugLog()
    -- local timestamp = GetSystemDate() .. " " .. GetSystemTime()
    -- InitLogFile( "log/boss_beta_introduction.txt", "[[ Introduction ]]\n")
    -- AppendToLogFile('log/boss_beta_introduction.txt', "["..timestamp.."] debug...\n")
end

function Boot:RegisterThinker()
end

function Boot:OnThink()
end
