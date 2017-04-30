-- Standard Required Files
for _,file in ipairs({

    -- Event first, needed for activation bindings.
    'app/core/event',

    'app/core/network/errors',
    'app/core/network/http',
    'app/core/network/reporter',
    'app/core/network/throttle',
    'app/core/boot',
    'app/core/filters',
    'app/core/sounds',

    'app/maps/'..GetMapName(),

    'app/systems/characters/abilities/wrappers',

    'app/systems/characters/character_pick',
    'app/systems/characters/character_service',
    'app/systems/characters/focus_target',
    'app/systems/characters/player_service',
    'app/systems/characters/player',
    'app/systems/characters/save_load',

    'app/systems/inventory/base_item',
    'app/systems/inventory/inventory_service',
    'app/systems/inventory/inventory',

    'app/systems/npcs/ai/units/ai_dark_boss_actions',
    'app/systems/npcs/ai/units/ai_dark_boss_logic',

    'app/systems/npcs/ai_mixin',
    'app/systems/npcs/base_npc_creature',
    'app/systems/npcs/creature_system',
    'app/systems/npcs/dialog_system',
    'app/systems/npcs/drops',
    'app/systems/npcs/encounter',
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

    'vendor/barebones/animations',
    -- 'vendor/barebones/containers',
    'vendor/barebones/notifications',
    'vendor/barebones/playertables',
    'vendor/barebones/timers',
    'vendor/inspect',
    'vendor/popupnumbers',
    'vendor/tracking_projectile',

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
    'ai_start_area_boss',
    'ai_webbed_queen',
    'ice_dungeon_boss3',
}) do LinkLuaModifier(modifier, 'app/systems/npcs/ai/units/'..modifier, LUA_MODIFIER_MOTION_NONE) end

LinkLuaModifier('webbed_spidy_bubble_death_cloud', 'app/systems/npcs/abilities/webbed_spidy_bubble_death_cloud', LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier('character_vision', 'app/systems/characters/modifiers/character_vision', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('character_passive_regen', 'app/systems/characters/modifiers/character_passive_regen', LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier('warrior_stats', 'app/systems/characters/abilities/warrior/warrior_stats', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('sorcerer_stats', 'app/systems/characters/abilities/sorcerer/sorcerer_stats', LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier('character_testmode', 'app/systems/characters/modifiers/character_testmode', LUA_MODIFIER_MOTION_NONE)
