
DEBUG_SETTINGS = IsInToolsMode()
-- Override if necessary...
DEBUG_SETTINGS = false

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
    OrderFilter       = true,
    CharacterService  = true,
    Reporter          = false,
    Triggers          = true,
    
    AiBasicSheep      = false,
    AiBasicAggro      = false,
    AiAggroLeash      = false,
    AiBasicNpc        = true,
    
    Spawn             = false,
    
    SpawnSystem       = true,
    NpcRepository     = true,
    QuestRepository   = true,
    Drops             = true,
    
    Event             = true,
    Filters           = true,
    NpcInteraction    = false,
    PrintTable        = true,
}
DEBUG_PRINT_ALL = false
