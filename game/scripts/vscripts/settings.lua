
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
    TEST_PICK_HERO = 'invoker'       -- Mage
    --TEST_PICK_HERO = 'warlock'       -- Sorcerer
    --TEST_PICK_HERO_ALT = 'omniknight'

    TEST_DISABLE_FOG = true
    TEST_START_LEVEL = 24
    --TEST_SUPERSTRONG = true
    --TEST_SUPERPATHEY = 2200
    -- town kobolds ice webbed druids dark
    TEST_START_WAYPOINT = 'dark'
    --TEST_START_START_BOSS = true
    TEST_START_DARK_BOSS = true
    TEST_QUESTS_COMPLETE = {
        ['1005'] = 'start_area_report_to_town',
        -- ['1012'] ='kobolds_warchief',
    }
    TEST_SPAWN_ITEMS = true
    TEST_ADD_ITEMS = {
        'item_3166',
        'item_3165',
        'item_3168',
        'item_3170',
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
    TEST_EQUIP_ITEMS_6 = {
        --[1] = '', -- helm
        [2] = 'item_amulet_tier2', -- neck
        [3] = 'item_armor_tier3', -- armor
        [8] = 'item_3146', -- ring
        [9] = 'item_amulet_scar', -- ring
        [10] = 'item_boots_leather_common', -- boots
        [11] = 'item_broadsword_tier4', -- weapon
        [12] = 'item_3147', -- shield
    }
    TEST_EQUIP_ITEMS_18 = {
        [1] = 'item_3125', -- helm
        [2] = 'item_3126', -- neck
        [3] = 'item_3137', -- armor
        [8] = 'item_kobold_amulet_1', -- ring
        [9] = 'item_amulet_scar', -- ring
        [10] = 'item_3129', -- boots
        [11] = 'item_3144', -- weapon
        [12] = 'item_3123', -- shield
    }
    TEST_EQUIP_ITEMS_20_TWINK = {
        [1] = 'item_3138', -- helm
        [2] = 'item_3139', -- neck
        [3] = 'item_3152', -- armor
        [8] = 'item_kobold_amulet_unique', -- ring
        [9] = 'item_kobold_amulet_unique', -- ring
        [10] = 'item_3129', -- boots
        [11] = 'item_3153', -- weapon
        [12] = 'item_3142', -- shield
    }
    TEST_EQUIP_ITEMS_MAX = {
        [1] = 'item_3138', -- helm
        [2] = 'item_3139', -- neck
        [3] = 'item_3152', -- armor
        [8] = 'item_kobold_amulet_unique', -- ring
        [9] = 'item_kobold_amulet_unique', -- ring
        [10] = 'item_3129', -- boots
        [11] = 'item_3153', -- weapon
        [12] = 'item_3142', -- shield
    }
    TEST_EQUIP_ITEMS = TEST_EQUIP_ITEMS_20_TWINK
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
    Spells            = true,
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
    AiDarkBoss        = true,
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
