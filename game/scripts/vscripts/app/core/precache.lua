
function PrecacheExecute(context)
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

        -- Game Effects
        'particles/effects/loot_expire/loot_expire.vpcf',
        'particles/transport_bird/transport_bird.vpcf',

        'particles/units/start/scar/claw.vpcf',
        'particles/units/start/scar/claw_swipe.vpcf',
        'particles/units/start/scar/scar_ground/scar_ground.vpcf',
        'particles/dire_fx/bad_ancient_ambient.vpcf', -- Dark Boss Barricade
        'particles/units/dark_plains/boss/energy_pull/energy_pull.vpcf', -- Dark Boss Link

        -- Spiders
        'particles/targeting/aoe_danger.vpcf',
        'particles/units/webbed/spider_spawn_poof.vpcf',

        -- Druids
        'particles/units/druids/protector/druids_protector_orb.vpcf',
        'particles/units/druids/glow/druids_glow_red.vpcf',
        'particles/units/druids/glow/druids_glow_blue.vpcf',
        'particles/units/druids/glow/druids_glow_green.vpcf',
        'particles/units/druids/glow/druids_glow_white.vpcf',
        'particles/units/heroes/hero_jakiro/jakiro_dual_breath_fire_d.vpcf',
        'particles/econ/courier/courier_dc/dccourier_angel_flame_trail.vpcf',
        'particles/econ/courier/courier_dc/dccourier_devil_flame_trail.vpcf',

        -- Testing?
        'particles/econ/items/venomancer/veno_ti8_immortal_head/veno_ti8_immortal_gale.vpcf',
        'particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf',
        'particles/econ/items/drow/drow_bow_monarch/drow_frost_arrow_monarch.vpcf',
        'particles/units/heroes/hero_drow/drow_frost_arrow.vpcf',
        'particles/econ/items/mirana/mirana_crescent_arrow/mirana_spell_crescent_arrow.vpcf',
        'particles/units/heroes/hero_legion_commander/legion_commander_odds_hero_arrow_parent.vpcf'
    }) do PrecacheResource('particle', name, context) end

    -- This is required for reconnected players.
    -- Should figure out how to add this to a kv...
    for _,name in ipairs({
        'models/heroes/invoker/invoker_head.vmdl', -- 98
        'models/items/invoker/sempiternal_revelations_hat_s1/sempiternal_revelations_hat_s1.vmdl', -- 6441
        'models/items/invoker/arsenal_magus_belt/arsenal_magus_belt.vmdl', -- 6200
        'models/items/dragon_knight/fire_tribunal_tabard/fire_tribunal_tabard.vmdl', -- 6105
        'models/items/dragon_knight/fire_tribunal_helm/fire_tribunal_helm.vmdl', -- 6099
        'models/items/dragon_knight/fire_tribunal_arms/fire_tribunal_arms.vmdl', -- 6093
        'models/items/dragon_knight/sword_of_the_drake/sword_of_the_drake.vmdl', -- 4503
        'models/items/dragon_knight/shield_timedragon.vmdl', -- 4095
        'models/heroes/omniknight/head.vmdl', -- 45
        'models/items/omniknight/stalwart_arms/stalwart_arms.vmdl', -- 7090
        'models/items/omniknight/stalwart_weapon/stalwart_weapon.vmdl', -- 7091
        'models/items/omniknight/stalwart_head/stalwart_head.vmdl', -- 7092
        'models/items/omniknight/stalwart_back/stalwart_back.vmdl', -- 7093
        'models/items/omniknight/stalwart_shoulder/stalwart_shoulder.vmdl', -- 7094
        'models/items/bounty_hunter/immortal_warrior_knife/immortal_warrior_knife.vmdl', -- 4830
        'models/items/bounty_hunter/immortal_warrior_blades/immortal_warrior_blades.vmdl', -- 4829
        'models/items/bounty_hunter/twinblades_back/twinblades_back.vmdl', -- 6527
        'models/items/bounty_hunter/twinblades_shoulder/twinblades_shoulder.vmdl', -- 6529
        'models/items/bounty_hunter/twinblades_armor/twinblades_armor.vmdl', -- 6537
        'models/items/bounty_hunter/twinblades_head/twinblades_head.vmdl', -- 6525
        'models/items/windrunner/ti6_windranger_back/ti6_windranger_back.vmdl', -- 7923
        'models/items/windrunner/deadly_feather_swing_head/deadly_feather_swing_head.vmdl', -- 8252
        'models/items/windrunner/ti6_windranger_shoulder/ti6_windranger_shoulder.vmdl', -- 7926
        'models/items/windrunner/the_swift_pathfinder_swift_pathfinders_bow/the_swift_pathfinder_swift_pathfinders_bow.vmdl', -- 8922
        'models/items/windrunner/ti6_windranger_offhand/ti6_windranger_offhand.vmdl', -- 7925
        'models/items/warlock/tevent_2_gatekeeper_head/tevent_2_gatekeeper_head.vmdl', -- 8079
        'models/items/warlock/archivists_robe/archivists_robe.vmdl', -- 4474
        'models/items/warlock/staff_of_infernal_chaos/staff_of_infernal_chaos.vmdl', -- 5424
        'models/heroes/warlock/warlock_lantern.vmdl', -- 6068
        'models/heroes/lone_druid/arms.vmdl',
        'models/items/lone_druid/hair_of_the_wolf_hunter/hair_of_the_wolf_hunter.vmdl',
        'models/items/lone_druid/dark_wood_back/dark_wood_back.vmdl',
        'models/items/lone_druid/shoulder_poor.vmdl',
        'models/items/keeper_of_the_light/wise_cap_of_the_first_light/wise_cap_of_the_first_light.vmdl',
        'models/items/keeper_of_the_light/spiral_staff_of_the_first_light/spiral_staff_of_the_first_light.vmdl',
        'models/items/keeper_of_the_light/gladys_the_lightbearing_mule_new/gladys_the_lightbearing_mule_new.vmdl',
        'models/items/keeper_of_the_light/robes_of_the_first_light/robes_of_the_first_light.vmdl',
    }) do
        PrecacheResource('model', name, context)
    end

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
        'soundevents/game_sounds.vsndevts',
        'soundevents/game_sounds_ui_imported.vsndevts',
        'soundevents/game_sounds_creeps.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_broodmother.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_centaur.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_chen.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_crystalmaiden.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_death_prophet.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_earthshaker.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_enigma.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_invoker.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_lina.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_lycan.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_omniknight.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_shadowshaman.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_skywrath_mage.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_techies.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_terrorblade.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_tusk.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_ursa.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_vengefulspirit.vsndevts',
        'soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts',
        'soundevents/music/jboberg_01/soundevents_music.vsndevts',
        'soundevents/music/jboberg_01/soundevents_stingers.vsndevts',
        'soundevents/voscripts/game_sounds_vo_beastmaster.vsndevts',
        'soundevents/voscripts/game_sounds_vo_death_prophet.vsndevts',
        'soundevents/voscripts/game_sounds_vo_lone_druid.vsndevts',
        'soundevents/voscripts/game_sounds_vo_pudge.vsndevts',
        'soundevents/voscripts/game_sounds_vo_lycan.vsndevts',
        'soundevents/sarynth.vsndevts',
    }
    for _,name in ipairs(sounds) do PrecacheResource('soundfile', name, context) end

    PrecacheItemByNameSync('item_amulet_tier1', context)
    PrecacheItemByNameSync('item_amulet_tier2', context)
    PrecacheItemByNameSync('item_amulet_tier3', context)

    for _,name in ipairs({
        'item_broadsword_tier1',
        'item_broadsword_tier2',
        'item_broadsword_tier3',
        'item_amulet_tier1',
        'item_amulet_tier2',
        'item_amulet_tier3',
        'item_amulet_scar',
        'item_3191',
        'item_3132',
        'item_3129',
        'item_kobold_weapon_2'
    }) do PrecacheItemByNameSync(name, context) end
    Debug('BootDebug', 'Precached Items')

    _G.GameItems = LoadKeyValues("scripts/items/items_game.txt")
    local heroes = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
    _G.GameUnits = LoadKeyValues("scripts/npc/npc_units_custom.txt")
    local cosmeticsParticles = {}

    for name,unit in pairs(GameUnits) do
        PrecacheUnitByNameSync(name, context)
        Debug('Precache', 'Unit', name)
    end
    for name,hero in pairs(heroes) do
        PrecacheUnitByNameSync(name, context)
        Debug('Precache', 'Hero', name)
    end

    Debug('BootDebug', 'Precache Complete')
end
