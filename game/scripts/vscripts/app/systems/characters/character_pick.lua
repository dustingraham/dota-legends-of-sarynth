---
--@type CharacterPick
CharacterPick = CharacterPick or class({})

function CharacterPick:Activate()
    Debug('CharacterPick', 'Activated!')

    -- May need to unregister this... to prevent abuse?
    ListenToGameEvent('player_connect_full', Dynamic_Wrap(CharacterPick, 'OnConnectFull'), self)

    CustomGameEventManager:RegisterListener('character_pick', Dynamic_Wrap(CharacterPick, 'OnCharacterPick'))
    CustomGameEventManager:RegisterListener('character_load', Dynamic_Wrap(CharacterPick, 'OnCharacterLoad'))
end

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

    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(PlayerID), 'character_picked', {})

    -- PlayerResource Replace/Select is not available quite yet...
    Timers:CreateTimer(0.01, function()
        CharacterPick:CreateCustomHeroForPlayer(PlayerID, pickHero, true)
    end)
end

---
-- This is currently the "create" character for new slots.
function CharacterPick:OnCharacterPick(event)
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    if hero:GetName() ~= DUMMY_HERO then
        Debug('CharacterPick', 'Unable to create. Already selected hero...')
        return
    end

    Debug('CharacterPick', 'OnCharacterPick PID:', event.PlayerID)

    -- Sound + Music for Standard Game Pick
    EmitSoundOnClient('HeroPicker.Selected', PlayerResource:GetPlayer(event.PlayerID))
    --GameRules:GetGameModeEntity():EmitSound('jboberg_01.music.ui_hero_select')

    local player = PlayerService:GetPlayer(event.PlayerID)
    player:SetCurrentSlot(event.slotId)
    player:SetCharacter(event.character)
    player:Save()

    CharacterPick:CreateCustomHeroForPlayer(
        event.PlayerID,
        player:GetCharacterHeroName(),
        true
    )
end

---
-- Used for character load by slot.
function CharacterPick:OnCharacterLoad(event)
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    if hero:GetName() ~= DUMMY_HERO then
        -- Seems to be common doubleclick issue of some sort.
        Debug('CharacterPick', 'Attempt by PID:', event.PlayerID)
        Debug('CharacterPick', 'For SlotID:', event.slotId)
        Debug('CharacterPick', 'Unable to load. Already selected hero...')
        return
    end

    Debug('CharacterPick', 'OnCharacterLoad PID:', event.PlayerID, 'Loading SlotID:', event.slotId)

    -- Sound for Standard Game Pick
    EmitSoundOnClient('HeroPicker.Selected', PlayerResource:GetPlayer(event.PlayerID))

    local player = PlayerService:GetPlayer(event.PlayerID)
    player:LoadSlot(event.slotId)

    CharacterPick:CreateCustomHeroForPlayer(
        event.PlayerID,
        player:GetCharacterHeroName(),
        true
    )
end

function CharacterPick:CreateCustomHeroForPlayer(PlayerID, character, isPrimary)
    -- Set zone if applicable
    local hero = PlayerResource:GetSelectedHeroEntity(PlayerID)
    local player = PlayerService:GetPlayer(PlayerID)
    if player:GetPriorZone() then
        -- Useless on wisp.
        --hero.currentZone = player:GetPriorZone()
        local point = Entities:FindByName(nil, player:GetPriorZone()..'_spawn_point')
        if point then
            hero:SetAbsOrigin(point:GetAbsOrigin())
        end
    end
    -- NOTE: This is PRE-Replace!

    -- Replace dummy unit with actual character
    local heroName = 'npc_dota_hero_'..character
    if isPrimary then
        Debug('CharacterPick', 'Replace Hero', heroName)
        PlayerResource:ReplaceHeroWith(PlayerID, heroName, 0, 0)
        hero = PlayerResource:GetSelectedHeroEntity(PlayerID)
        hero:SetAbsOrigin(hero:GetAbsOrigin())
    else
        -- TODO: Probably won't work idk.
        Debug('CharacterPick', 'Create Hero', heroName)
        hero = CreateHeroForPlayer(heroName, PlayerResource:GetPlayer(PlayerID))
        hero:SetControllableByPlayer(PlayerID, false)
        hero:SetAbsOrigin(hero:GetAbsOrigin())
        hero:SetOwner(PlayerResource:GetPlayer(PlayerID))
    end

    hero:SetAbilityPoints(0)
    for i = 0, hero:GetAbilityCount() - 1 do
        -- Note: Ability11 will bump down in index if there are no other abilities.
        local talent = hero:GetAbilityByIndex(i)
        if talent then talent:SetLevel(1) end
    end

    -- Standard vision past trees.
    hero:AddNewModifier(hero, nil, 'character_vision', nil)

    -- Regen while passive.
    hero:AddNewModifier(hero, nil, 'character_passive_regen', nil)

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
            -- 'models/items/omniknight/omniknight_sacred_light_head/omniknight_sacred_light_head.vmdl',
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

    if character == 'dragon_knight' then
        hero:AddNewModifier(hero, nil, 'warrior_stats', nil)
    end

    if character == 'bounty_hunter' then
        hero:AddNewModifier(hero, nil, 'rogue_stats', nil)
    end

    if character == 'warlock' then
        hero:AddNewModifier(hero, nil, 'sorcerer_stats', nil)
        local idx = ParticleManager:CreateParticle(
        'particles/units/heroes/hero_warlock/warlock_ambient_smoke.vpcf',
        PATTACH_POINT_FOLLOW,
        hero
        )
        ParticleManager:SetParticleControlEnt(idx, 0, hero, PATTACH_POINT_FOLLOW, 'attach_attack2', hero:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(idx)

        idx = ParticleManager:CreateParticle(
        'particles/units/heroes/sorcerer/sorcerer_ambient_staff.vpcf',
        PATTACH_POINT_FOLLOW,
        hero
        )
        ParticleManager:SetParticleControlEnt(idx, 0, hero, PATTACH_POINT_FOLLOW, 'attach_attack1', hero:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(idx, 1, hero:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(idx)
    end

    -- Level/Experience
    if player:GetPriorExperience() then
        hero.isInitialLevel = true
        hero:AddExperience(player:GetPriorExperience(), DOTA_ModifyXP_Unspecified, false, true)
        hero.isInitialLevel = nil
    end

    -- Gold
    if player:GetPriorGold() ~= nil then
        hero:SetGold(player:GetPriorGold(), true)
    end

    -- Current Zone
    if player:GetPriorZone() then
        hero.currentZone = player:GetPriorZone()
    end

    -- Teleports
    if player:GetKnownTeleports() then
        hero.unlockedTeleports = player:GetKnownTeleports()
    else
        hero.unlockedTeleports = {}
    end

    -- TODO: TEST SERVICE ?
    if TEST_KNOWN_TELEPORTS then
        for _,teleport in pairs(TEST_KNOWN_TELEPORTS) do
            hero.unlockedTeleports[teleport] = true
        end
    end

    Event:Trigger('HeroPick', {
        hero = hero,
        player = player,
        PlayerID = PlayerID
    })
end

function CharacterPick:AddCosmetic(hero, thing)
    -- Track, and remove with:  cosmetic:RemoveSelf()
    SpawnEntityFromTableSynchronous("prop_dynamic", { model = thing } ):FollowEntity(hero, true)
end

-- On Reconnect (?)
function CharacterPick:OnConnectFull(event)
    Debug('CharacterPick', 'OnConnectFull PID:', event.PlayerID)
    --DeepPrintTable(event)
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    if hero and hero:GetName() ~= DUMMY_HERO then
        Debug('CharacterPick', 'Possible reconnect.')
        -- Bypass pick screen.
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(event.PlayerID), 'character_picked', {})
    end
end

if not CharacterPick.initialized then
    CharacterPick.initialized = true
    Event:Listen('Activate', Dynamic_Wrap(CharacterPick, 'Activate'), CharacterPick)
end
