
DEBUG_SETTINGS = IsInToolsMode()
-- Override if necessary...
-- DEBUG_SETTINGS = false

DEBUG_SETTINGS_FOG = true
if DEBUG_SETTINGS then
    DEBUG_SETTINGS_FOG = false
end

DEBUG_SKIP_HTTP_REPORT = false
DEBUG_SKIP_HTTP_LOAD = true
DEBUG_SKIP_HTTP_SAVE = true

DEBUG_PRINT = true
DEBUG_PRINT_SECTIONS = {
    AddonGameMode     = true,
    Boot              = true,
    Http              = true,
    CharacterPick     = true,
    PlayerService     = true,
    CustomMap         = true,
    QuestService      = true,
    QuestGiver        = true,
    Quest             = true,
    OrderFilter       = true,
    CharacterService  = true,
    Reporter          = false,
    Triggers          = true,
    
    AiBasic           = true,
    AiBasicSheep      = false,
    AiBasicAggro      = false,
    AiAggroLeash      = false,
    AiBasicNpc        = true,
    
    Spawn             = false,
    
    SpawnSystem       = true,
    NpcRepository     = true,
    QuestRepository   = true,
    Drops             = true,
    DialogSystem      = true,
    Event             = true,
    Filters           = true,
    Interaction       = true,
    PrintTable        = true,
}
DEBUG_PRINT_ALL = false

-- TEST MODE
TEST_SPAWN_ITEMS = false
--TEST_PICK_HERO = 'dragon_knight' -- Warrior
--TEST_PICK_HERO = 'omniknight'    -- Paladin
--TEST_PICK_HERO = 'bounty_hunter' -- Rogue
--TEST_PICK_HERO = 'windrunner'    -- Ranger
TEST_PICK_HERO = 'invoker'       -- Mage
--TEST_PICK_HERO = 'warlock'       -- Sorcerer
