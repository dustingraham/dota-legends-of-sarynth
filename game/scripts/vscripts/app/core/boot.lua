---
--@type Boot
Boot = Boot or {}

DUMMY_HERO = 'npc_dota_hero_wisp'

function Boot:Precache(context)
    Debug('Boot', 'Precache')
    
    -- PrecacheResource( "model", "*.vmdl", context )
    -- PrecacheResource( "soundfile", "*.vsndevts", context )
    -- PrecacheResource( "particle", "*.vpcf", context )
    -- PrecacheResource( "particle_folder", "particles/folder", context )
    
--    PrecacheResource('particle', 'particles/units/heroes/hero_ursa/ursa_earthshock.vpcf', context)
--    PrecacheResource('particle', 'particles/quest_available.vpcf', context)
--    
--    PrecacheResource('soundfile', 'soundevents/game_sounds_heroes/game_sounds_shadowshaman.vsndevts', context)
--    PrecacheResource('soundfile', 'soundevents/game_sounds_heroes/game_sounds_ursa.vsndevts', context)
--    PrecacheResource("soundfile", "soundevents/music/jboberg_01/soundevents_music.vsndevts", context)
--    
--    PrecacheUnitByNameSync("npc_dota_hero_dragon_knight", context)
--    PrecacheUnitByNameSync("npc_dota_hero_invoker", context)
--    
--    PrecacheUnitByNameSync('npc_dota_hero_omniknight', context) -- Intro Sound
--    PrecacheUnitByNameSync("npc_dota_hero_lina", context)
--    
--    PrecacheUnitByNameSync("sheep", context)
--    PrecacheUnitByNameSync("quest_bear", context)
--    
--    PrecacheItemByNameSync('item_amulet_tier1', context)
end

function Boot:Activate()
    Debug('Boot', 'Activate')
    
    ListenToGameEvent('player_connect_full', Dynamic_Wrap(Boot, 'OnConnectFull'), self)
    ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(Boot, 'OnGameRulesStateChange'), self)
    
    CustomMap:Activate()
    
    Boot:InitGameRules()
    Boot:InitGameModeEntity()
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
    PlayerResource:SetCustomTeamAssignment(0, DOTA_TEAM_GOODGUYS)
    GameRules:SetCustomGameSetupTimeout(0)
    GameRules:SetStrategyTime(0)
    GameRules:SetShowcaseTime(0)
    GameRules:SetPreGameTime(0)
    
    GameRules:SetCustomGameSetupAutoLaunchDelay(0)
    GameRules:LockCustomGameSetupTeamAssignment(true)
    GameRules:EnableCustomGameSetupAutoLaunch(true)
    
    GameRules:SetPostGameTime(60)
    
    -- Trees
    GameRules:SetTreeRegrowTime(30)
    
    -- For reference
    -- GameRules:SetHeroSelectionTime(0)
    -- GameRules:SetCustomGameEndDelay(-1)
    -- GameRules:SetHeroRespawnEnabled(false)
    -- GameRules:SetUseUniversalShopMode(true)
    -- GameRules:SetSameHeroSelectionEnabled(true)
    -- GameRules:SetUseCustomHeroXPValues(false)
    -- GameRules:SetGoldPerTick(GOLD_PER_TICK)
    -- GameRules:SetGoldTickTime(GOLD_TICK_TIME)
    -- GameRules:SetRuneSpawnTime(RUNE_SPAWN_TIME)
    -- GameRules:SetUseBaseGoldBountyOnHeroes(USE_STANDARD_HERO_GOLD_BOUNTY)
    -- GameRules:SetHeroMinimapIconScale( MINIMAP_ICON_SIZE )
    -- GameRules:SetCreepMinimapIconScale( MINIMAP_CREEP_ICON_SIZE )
    -- GameRules:SetRuneMinimapIconScale( MINIMAP_RUNE_ICON_SIZE )
    -- GameRules:SetFirstBloodActive( ENABLE_FIRST_BLOOD )
    -- GameRules:SetHideKillMessageHeaders( HIDE_KILL_BANNERS )
    -- GameRules:SetCustomVictoryMessageDuration( VICTORY_MESSAGE_DURATION )
    -- GameRules:SetStartingGold( STARTING_GOLD )
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
    mode:SetFogOfWarDisabled(not DEBUG_SETTINGS_FOG)
    mode:SetUnseenFogOfWarEnabled(DEBUG_SETTINGS_FOG)
    
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
    mode:SetUseCustomHeroLevels(true)
    mode:SetCustomXPRequiredToReachNextLevel({
        0, -- Level 1
        100, -- Level 2
        200, -- Level 3
        350, -- Level 4
        500, -- Level 5
        700, -- Level 6
        900, -- Level 7
        1200, -- Level 8
        1600, -- Level 9
        2400, -- Level 10
    })
    
    Debug('Boot', 'Configured GameModeEntity')
end

function Boot:OnConnectFull(event)
    Debug('Boot', 'OnConnectFull')
--    PlayerService:OnConnectFull(event)
end

function Boot:OnGameRulesStateChange()
    Debug('Boot', 'State Change :',GameRules:State_Get())
    
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        -- If we are in tools mode, there is no worry about a duplicate match from concurrent start time.
        if not IsInToolsMode() then
            -- If we are live, then Valve handles the match ID value.
            Boot.MatchID = tostring(GameRules:GetMatchID())
        end
        
--        QuestRepository:Init()
--        NpcRepository:Init()
--        Drops:Init()
--        
--        SpawnService:Init()
--        CharacterService:Init()
--        PlayerService:Init()
--        QuestService:Init()
--        
--        Filters:Activate()
--        NpcInteraction:Activate()
        
        Event:Trigger('OnStateGameSetup')
        
--        local key = 'Setup_'..GetMapName()
--        if Boot[key] then
--            Boot[key](self)
--        else
--            Debug('Boot', 'Routine missing: ', key)
--        end
    end
    
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        Event:Trigger('OnStateInGame')
--        local key = 'InGame_'..GetMapName()
--        if Boot[key] then
--            Boot[key](self)
--        else
--            Debug('Boot', 'Routine missing: ', key)
--        end
    end
end

function Boot:DebugLog()
    -- local timestamp = GetSystemDate() .. " " .. GetSystemTime()
    -- InitLogFile( "log/boss_beta_introduction.txt", "[[ Introduction ]]\n")
    -- AppendToLogFile('log/boss_beta_introduction.txt', "["..timestamp.."] debug...\n")
end
