
DEBUG_SETTINGS = IsInToolsMode()
-- Override if necessary...
DEBUG_SETTINGS = false

-- TEST MODE
if DEBUG_SETTINGS then
    -- Curronly only a single hero. Pick it!
    --TEST_PICK_HERO = 'windrunner'    -- Ranger
    --TEST_PICK_HERO = 'dragon_knight' -- Warrior
    --TEST_PICK_HERO = 'omniknight'    -- Paladin
    TEST_PICK_HERO = 'bounty_hunter' -- Rogue
    --TEST_PICK_HERO = 'invoker'       -- Mage
    --TEST_PICK_HERO = 'warlock'       -- Sorcerer
    --TEST_PICK_HERO_ALT = 'omniknight'

    TEST_DISABLE_FOG = true
    TEST_SPAWN_ITEMS = true
    TEST_START_LEVEL = 8
    --TEST_SUPERMAN = true
    -- town kobolds ice webbed druids dark
    TEST_START_WAYPOINT = 'kobolds'
    --TEST_START_START_BOSS = true
    TEST_QUESTS_COMPLETE = {
        ['1005'] = 'start_area_report_to_town'
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
    Triggers          = true,
    AiBasic           = true,
    AiBasicSheep      = false,
    AiBasicAggro      = false,
    AiAggroLeash      = false,
    AiBasicNpc        = true,
    StartAreaBoss     = true,
    Encounter         = true,
    Spawn             = false,
    FocusTarget       = false,
    SpawnSystem       = true,
    NpcRepository     = true,
    QuestRepository   = true,
    Drops             = true,
    DialogSystem      = true,
    Event             = true,
    Filters           = false,
    Interaction       = true,
    PrintTable        = true,
    InventoryService  = true,
    Inventory         = true,
}
DEBUG_PRINT_ALL = false
