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

    for _,name in ipairs({
        -- Ranger
        'particles/units/heroes/hero_windrunner/windrunner_bowstring.vpcf',
        'particles/units/heroes/ranger/ice_arrow/ranger_ice_arrow.vpcf',
        'particles/units/heroes/ranger/poison_arrow/ranger_poison_arrow.vpcf',
        'particles/units/heroes/ranger/concussive_shot/ranger_concussive_shot.vpcf',
        'particles/units/heroes/ranger/strong_shot/ranger_strong_shot.vpcf',
        'particles/units/heroes/ranger/explosive_shot/ranger_explosive_shot.vpcf',
        'particles/units/heroes/ranger/explosive_shot/ranger_explosive_shot_impact.vpcf',

         'particles/units/start/scar/claw.vpcf',

        -- Testing?
        'particles/econ/items/drow/drow_bow_monarch/drow_frost_arrow_monarch.vpcf',
        'particles/units/heroes/hero_drow/drow_frost_arrow.vpcf',
        'particles/econ/items/mirana/mirana_crescent_arrow/mirana_spell_crescent_arrow.vpcf',
        'particles/units/heroes/hero_legion_commander/legion_commander_odds_hero_arrow_parent.vpcf'
    }) do PrecacheResource('particle', name, context) end


    PrecacheResource('particle', 'particles/units/heroes/hero_ursa/ursa_earthshock.vpcf', context)
    PrecacheResource('particle', 'particles/quest_available.vpcf', context)

    -- Level Up
    PrecacheResource('particle', 'particles/econ/events/ti6/hero_levelup_ti6.vpcf', context)

    -- Ice Barricade
    PrecacheResource('particle', 'particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf', context)
    PrecacheResource('particle', 'particles/econ/items/ancient_apparition/aa_blast_ti_5/ancient_apparition_ice_blast_explode_ti5.vpcf', context)

    -- Spells
    PrecacheResource('particle', 'particles/units/heroes/hero_lina/lina_base_attack.vpcf', context)

    PrecacheResource('particle', 'particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_arcana_body_ambient.vpcf', context)
    PrecacheResource('particle', 'particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_death_arcana.vpcf', context)
    -- Spell Testing
    PrecacheResource('particle', 'particles/econ/items/abaddon/abaddon_alliance/abaddon_death_coil_alliance.vpcf', context)

    local sounds = {
        'soundevents/game_sounds_creeps.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_broodmother.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_crystalmaiden.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_lina.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_lycan.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_omniknight.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_shadowshaman.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_terrorblade.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_tusk.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_ursa.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_vengefulspirit.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts',
        'soundevents/music/jboberg_01/soundevents_music.vsndevts',
        'soundevents/music/jboberg_01/soundevents_stingers.vsndevts',
        'soundevents/voscripts/game_sounds_vo_beastmaster.vsndevts',
        'soundevents/voscripts/game_sounds_vo_lycan.vsndevts',
    }
    for _,name in ipairs(sounds) do PrecacheResource('soundfile', name, context) end

    PrecacheItemByNameSync('item_amulet_tier1', context)
    PrecacheItemByNameSync('item_amulet_tier2', context)
    PrecacheItemByNameSync('item_amulet_tier3', context)

    _G.GameItems = LoadKeyValues("scripts/items/items_game.txt")
    local heroes = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
    local units = LoadKeyValues("scripts/npc/npc_units_custom.txt")
    local cosmeticsParticles = {}

    for name,unit in pairs(units) do
        PrecacheUnitByNameSync(name, context)
        Debug('Precache', 'Unit', name)
    end
    for name,hero in pairs(heroes) do
        PrecacheUnitByNameSync(name, context)
        Debug('Precache', 'Hero', name)
    end

end

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
