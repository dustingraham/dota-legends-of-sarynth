-- Standard Required Files
for _,file in ipairs({
    
    'app/core/network/errors',
    'app/core/network/http',
    'app/core/network/reporter',
    'app/core/network/throttle',
    'app/core/boot',
    'app/core/event',
    'app/core/filters',
    'app/core/sounds',
    
    'app/maps/'..GetMapName(),
    
    'app/systems/characters/abilities/wrappers',
    
    'app/systems/characters/character_pick',
    'app/systems/characters/character_service',
    'app/systems/characters/focus_target',
    'app/systems/characters/player_service',
    'app/systems/characters/player',
    
    'app/systems/npcs/base_npc_creature',
    'app/systems/npcs/dialog_system',
    'app/systems/npcs/drops',
    'app/systems/npcs/interaction',
    'app/systems/npcs/spawn_node',
    'app/systems/npcs/spawn_system',
    'app/systems/npcs/spawn',
    
    'app/systems/quests/quest_giver',
    'app/systems/quests/quest_repository',
    'app/systems/quests/quest_service',
    'app/systems/quests/quest_system',
    'app/systems/quests/quest',
    
    'app/utils/debug',
    'app/utils/helpers',
    'app/utils/md5',
    
    'vendor/barebones/containers',
    'vendor/barebones/notifications',
    'vendor/barebones/playertables',
    'vendor/barebones/timers',
    'vendor/inspect',
    'vendor/popupnumbers',
    
    'settings',
    
}) do require(file) end

-- AI Modifiers
for _,modifier in ipairs({
    'ai_dark_boss',
    'ai_aggro_leash',
    'ai_basic_aggro',
    'ai_basic_sheep',
    'ai_basic',
    'ai_npc_basic',
}) do LinkLuaModifier(modifier, 'app/systems/npcs/ai/'..modifier, LUA_MODIFIER_MOTION_NONE) end
for _,modifier in ipairs({
    'ice_dungeon_boss3',
}) do LinkLuaModifier(modifier, 'app/systems/npcs/ai/units/'..modifier, LUA_MODIFIER_MOTION_NONE) end
