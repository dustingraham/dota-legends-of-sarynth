---
--@type CharacterPick
CharacterPick = CharacterPick or class({})

function CharacterPick:TestMapPickAll(heroReal)
    Debug('CharacterPick', 'Picking all for test map.')

    -- This gets purged after the first create...
    local PlayerID = heroReal:GetPlayerOwnerID()

    -- PlayerResource Replace/Select is not available quite yet...
    Timers:CreateTimer(0.01, function()
        CharacterPick:CreateCustomHeroForPlayer(PlayerID, 'warlock', true)
        for _,character in pairs({
--            'dragon_knight', -- Warrior
--            'omniknight', -- Paladin
--            'bounty_hunter', -- Rogue
--            'windrunner', -- Ranger
--            'invoker', -- Mage
--            'warlock', -- Sorcerer
        }) do
            CharacterPick:CreateCustomHeroForPlayer(PlayerID, character, false)
        end
    end)
end

function CharacterPick:TestMapPickHero(heroReal, pickHero)
    Debug('CharacterPick', 'Picking '..pickHero)

    -- This gets purged after the first create...
    local PlayerID = heroReal:GetPlayerOwnerID()

    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(id), 'character_picked', {})

    -- PlayerResource Replace/Select is not available quite yet...
    Timers:CreateTimer(0.01, function()
        CharacterPick:CreateCustomHeroForPlayer(PlayerID, pickHero, true)
    end)
end

---
-- This is currently the "create" character for new slots.
function CharacterPick:OnCharacterPick(event)
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    if hero:GetName() ~= DUMMY_HERO then Debug('CharacterPick', 'Already selected hero...') return end

    -- Sound + Music for Standard Game Pick
    EmitSoundOnClient('HeroPicker.Selected', PlayerResource:GetPlayer(event.PlayerID))
    GameRules:GetGameModeEntity():EmitSound('jboberg_01.music.ui_hero_select')

    local player = PlayerService:GetPlayer(event.PlayerID)
    player:SetCurrentSlot(event.slotId)
    player:SetCharacter(event.character)
    player:Save()

    local translateCharacter = {
        Warrior = 'dragon_knight',
        Paladin = 'omniknight',
        Rogue = 'bounty_hunter',
        Ranger = 'windrunner',
        Mage = 'invoker',
        Sorcerer = 'warlock'
    }

    CharacterPick:CreateCustomHeroForPlayer(
        event.PlayerID,
        translateCharacter[event.character],
        event.slotId,
        true
    )
end

---
-- Used for character load by slot.
function CharacterPick:OnCharacterLoad(event)
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    if hero:GetName() ~= DUMMY_HERO then Debug('CharacterPick', 'Already selected hero...') return end

    -- Sound + Music for Standard Game Pick
    EmitSoundOnClient('HeroPicker.Selected', PlayerResource:GetPlayer(event.PlayerID))
    GameRules:GetGameModeEntity():EmitSound('jboberg_01.music.ui_hero_select')

    local player = PlayerService:GetPlayer(event.PlayerID)
    player:LoadSlot(event.slotId)
    local character = player:GetCharacter()

    local translateCharacter = {
        Warrior = 'dragon_knight',
        Paladin = 'omniknight',
        Rogue = 'bounty_hunter',
        Ranger = 'windrunner',
        Mage = 'invoker',
        Sorcerer = 'warlock'
    }

    CharacterPick:CreateCustomHeroForPlayer(
        event.PlayerID,
        translateCharacter[character],
        event.slotId,
        true
    )
end

function CharacterPick:CreateCustomHeroForPlayer(PlayerID, character, slotId, isPrimary)
    local hero
    local heroName = 'npc_dota_hero_'..character
    if isPrimary then
        Debug('CharacterPick', 'Replace Hero', heroName)
        PlayerResource:ReplaceHeroWith(PlayerID, heroName, 0, 0)
        hero = PlayerResource:GetSelectedHeroEntity(PlayerID)
    else
        Debug('CharacterPick', 'Create Hero', heroName)
        local player = PlayerResource:GetPlayer(PlayerID)
        hero = CreateHeroForPlayer(heroName, player)
        hero:SetControllableByPlayer(PlayerID, false)
        -- hero:SetOwner(player)
    end
    hero.slotId = slotId

    hero:SetAbilityPoints(0)
    -- hero:GetAbilityByIndex(0):SetLevel(1)
    for i = 0, 5 do
        hero:GetAbilityByIndex(i):SetLevel(1)
    end


    -- Standard vision past trees.
    hero:AddNewModifier(nil, nil, 'character_vision', nil)

    local cosmetics = {
        invoker = {
            -- Head
            'models/heroes/invoker/invoker_head.vmdl', -- 98

            -- Hair/Hat
            --'models/heroes/invoker/invoker_hair.vmdl',
            --'models/items/invoker/sinisterlightning_head_s1/sinisterlightning_head_s1.vmdl',
            'models/items/invoker/sempiternal_revelations_hat_s1/sempiternal_revelations_hat_s1.vmdl', -- 6441


            -- Garbs of the eastern range look pretty low key...
            -- Might be tier 1...


            -- Minor Sholders
            --'models/items/invoker/pads_of_the_eastern_range/pads_of_the_eastern_range.vmdl',

            -- Cape
            --'models/items/invoker/arsenal_magus_wex_cape/arsenal_magus_wex_cape.vmdl',

            -- Bottom/Belt/Dress
            'models/items/invoker/arsenal_magus_belt/arsenal_magus_belt.vmdl', -- 6200

        },
        dragon_knight = {
            -- DK = Fire Tribunal Set

            -- Chest
            'models/items/dragon_knight/fire_tribunal_tabard/fire_tribunal_tabard.vmdl', -- 6105

            -- Helm
            'models/items/dragon_knight/fire_tribunal_helm/fire_tribunal_helm.vmdl', -- 6099

            -- Arms
            'models/items/dragon_knight/fire_tribunal_arms/fire_tribunal_arms.vmdl', -- 6093

            -- Sword
            'models/items/dragon_knight/sword_of_the_drake/sword_of_the_drake.vmdl', -- 4503
            --'models/heroes/dragon_knight/weapon.vmdl', -- Tier 2
            --'models/items/dragon_knight/fire_tribunal_sword/fire_tribunal_sword.vmdl',
            --'models/items/dragon_knight/weapon_dragonmaw.vmdl',
            --'models/items/dragon_knight/wurmblood_weapon/wurmblood_weapon.vmdl', -- Lance

            -- But, weaker shield. (Maybe wyrm shield of uldorak)
            -- Shield
            'models/items/dragon_knight/shield_timedragon.vmdl', -- 4095
        },
        omniknight = {
            'models/heroes/omniknight/head.vmdl', -- 45
            'models/items/omniknight/stalwart_arms/stalwart_arms.vmdl', -- 7090
            'models/items/omniknight/stalwart_weapon/stalwart_weapon.vmdl', -- 7091
            'models/items/omniknight/stalwart_head/stalwart_head.vmdl', -- 7092
            'models/items/omniknight/stalwart_back/stalwart_back.vmdl', -- 7093
            'models/items/omniknight/stalwart_shoulder/stalwart_shoulder.vmdl', -- 7094
        },
        bounty_hunter = {
            'models/items/bounty_hunter/immortal_warrior_knife/immortal_warrior_knife.vmdl', -- 4830
            'models/items/bounty_hunter/immortal_warrior_blades/immortal_warrior_blades.vmdl', -- 4829
            'models/items/bounty_hunter/twinblades_back/twinblades_back.vmdl', -- 6527
            'models/items/bounty_hunter/twinblades_shoulder/twinblades_shoulder.vmdl', -- 6529
            'models/items/bounty_hunter/twinblades_armor/twinblades_armor.vmdl', -- 6537
            'models/items/bounty_hunter/twinblades_head/twinblades_head.vmdl', -- 6525
        },
        windrunner = {
            'models/items/windrunner/ti6_windranger_back/ti6_windranger_back.vmdl', -- 7923
            --'models/items/windrunner/ti6_windranger_head/ti6_windranger_head.vmdl',
            'models/items/windrunner/deadly_feather_swing_head/deadly_feather_swing_head.vmdl', -- 8252
            'models/items/windrunner/ti6_windranger_shoulder/ti6_windranger_shoulder.vmdl', -- 7926

            'models/items/windrunner/the_swift_pathfinder_swift_pathfinders_bow/the_swift_pathfinder_swift_pathfinders_bow.vmdl', -- 8922
            'models/items/windrunner/ti6_windranger_offhand/ti6_windranger_offhand.vmdl', -- 7925
        },
        warlock = {
            -- Helm
            'models/items/warlock/tevent_2_gatekeeper_head/tevent_2_gatekeeper_head.vmdl', -- 8079

            -- Robes
            'models/items/warlock/archivists_robe/archivists_robe.vmdl', -- 4474

            -- Staff
            'models/items/warlock/staff_of_infernal_chaos/staff_of_infernal_chaos.vmdl', -- 5424

            -- Offhand
            'models/heroes/warlock/warlock_lantern.vmdl', -- 6068
        }
    }
    if cosmetics[character] then
        -- local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
        for _,name in pairs(cosmetics[character]) do
            CharacterPick:AddCosmetic(hero, name)
        end
    end

    if character == 'windrunner' then
        local particleName = 'particles/units/heroes/hero_windrunner/windrunner_bowstring.vpcf'
        local idx = ParticleManager:CreateParticle(
        particleName,
        PATTACH_POINT_FOLLOW,
        hero
        )
        ParticleManager:SetParticleControlEnt(idx, 0, hero, PATTACH_POINT_FOLLOW, 'bow_bot', hero:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(idx, 1, hero, PATTACH_POINT_FOLLOW, 'bow_mid', hero:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(idx, 2, hero, PATTACH_POINT_FOLLOW, 'bow_top', hero:GetAbsOrigin(), true)

        ParticleManager:ReleaseParticleIndex(idx)
    end

    -- Load Data
    --if not DEBUG_SKIP_HTTP_LOAD then
    --    Http:Load({
    --                  steamId64 = tostring(PlayerResource:GetSteamID(event.PlayerID)),
    --                  hero = hero:GetName(),
    --              }, function(data)
    --        Debug('CharacterPick', 'Player Loaded')
    --        DeepPrintTable(data)
    --        if data.experience then
    --            local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    --            hero.isInitialLevel = true
    --            hero:AddExperience(data.experience, 0, false, false)
    --            hero.isInitialLevel = nil
    --        end
    --    end)
    --end

    local player = PlayerService:GetPlayer(PlayerID)
    if player.experience then
        hero.isInitialLevel = true
        -- Currently broken locally. Adding 20% too much.
        hero:AddExperience(player.experience, DOTA_ModifyXP_Unspecified, false, true)
        hero.isInitialLevel = nil
    end

    Event:Trigger('HeroPick', {
        hero = hero,
        PlayerID = PlayerID
    })
end

function CharacterPick:AddCosmetic(hero, thing)
    -- Track, and remove with:  cosmetic:RemoveSelf()
    SpawnEntityFromTableSynchronous("prop_dynamic", { model = thing } ):FollowEntity(hero, true)
end

if not CharacterPick.initialized then
    CharacterPick.initialized = true
    -- May need to unregister this... to prevent abuse?
    CustomGameEventManager:RegisterListener('character_pick', Dynamic_Wrap(CharacterPick, 'OnCharacterPick'))
    CustomGameEventManager:RegisterListener('character_load', Dynamic_Wrap(CharacterPick, 'OnCharacterLoad'))
end

LinkLuaModifier('character_vision', 'app/systems/characters/modifiers/character_vision', LUA_MODIFIER_MOTION_NONE)
