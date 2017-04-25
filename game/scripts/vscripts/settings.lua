
DEBUG_SETTINGS = IsInToolsMode()
-- Override if necessary...
--DEBUG_SETTINGS = false

-- TEST MODE
if DEBUG_SETTINGS then
    -- Curronly only a single hero. Pick it!
    --TEST_PICK_HERO = 'windrunner'    -- Ranger
    --TEST_PICK_HERO = 'dragon_knight' -- Warrior
    --TEST_PICK_HERO = 'omniknight'    -- Paladin
    --TEST_PICK_HERO = 'bounty_hunter' -- Rogue
    --TEST_PICK_HERO = 'invoker'       -- Mage
    TEST_PICK_HERO = 'warlock'       -- Sorcerer
    --TEST_PICK_HERO_ALT = 'omniknight'

    TEST_DISABLE_FOG = true
    TEST_START_LEVEL = 6
    --TEST_SUPERSTRONG = true
    --TEST_SUPERPATHEY = 3500
    -- town kobolds ice webbed druids dark
    --TEST_START_WAYPOINT = 'webbed'
    TEST_START_START_BOSS = true
    TEST_QUESTS_COMPLETE = {
        ['1005'] = 'start_area_report_to_town',
        ['1012'] ='kobolds_warchief',
    }
    TEST_SPAWN_ITEMS = true
    TEST_ADD_ITEMS = {
        --- Level 6 items
        'item_armor_tier3',
        'item_amulet_tier2',
        'item_broadsword_tier4',
        'item_boots_leather_common',
        'item_3135',
        --- Test Items
        'item_3149',
        'item_3153',
        'item_3154', -- Set Equip
        'item_3155',
        'item_3156',
        'item_3157',
        'item_3158',
        'item_3159',
        'item_3160',
        'item_3161',
        'item_3162',
    }
end

DEBUG_SKIP_HTTP_REPORT = DEBUG_SETTINGS
DEBUG_SKIP_HTTP_LOAD = DEBUG_SETTINGS or true
DEBUG_SKIP_HTTP_SAVE = DEBUG_SETTINGS or true

DEBUG_PRINT = true
DEBUG_PRINT_SECTIONS = {
    AddonGameMode     = true,
    Boot              = true,
    Precache          = false,
    Http              = true,
    CharacterPick     = true,
    PlayerService     = true,
    CustomMap         = true,
    QuestService      = false,
    QuestGiver        = true,
    Quest             = false,
    OrderFilter       = true,
    CharacterService  = true,
    Reporter          = false,
    ReporterVerbose   = false,
    Triggers          = true,
    TriggersVerbose   = false,
    AiBasic           = true,
    AiBasicSheep      = false,
    AiBasicAggro      = false,
    AiAggroLeash      = false,
    AiBasicNpc        = true,
    AiWebbedQueen     = true,
    StartAreaBoss     = true,
    Encounter         = true,
    Spawn             = false,
    FocusTarget       = false,
    SpawnSystem       = true,
    NpcRepository     = true,
    QuestRepository   = true,
    Drops             = false,
    DialogSystem      = true,
    Event             = true,
    Filters           = false,
    Interaction       = true,
    PrintTable        = true,
    InventoryService  = true,
    Inventory         = true,
}
DEBUG_PRINT_ALL = false
