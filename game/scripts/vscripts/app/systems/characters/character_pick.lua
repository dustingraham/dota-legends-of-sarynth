---
--@type CharacterPick
CharacterPick = CharacterPick or class({})

function CharacterPick:TestMapPickAll(heroReal)
    Debug('CharacterPick', 'Picking all for test map.')
    
    -- This gets purged after the first create...
    local id = heroReal:GetPlayerOwnerID()
    
    -- PlayerResource Replace/Select is not available quite yet...
    Timers:CreateTimer(0.01, function()
        CharacterPick:CreateCustomHeroForPlayer({
            ['PlayerID'] = id,
            ['character'] = 'warlock',
            ['create'] = false
        })
        for _,character in pairs({
--            'dragon_knight', -- Warrior
--            'omniknight', -- Paladin
--            'bounty_hunter', -- Rogue
--            'windrunner', -- Ranger
--            'invoker', -- Mage
--            'warlock', -- Sorcerer     
        }) do
            CharacterPick:CreateCustomHeroForPlayer({
                ['PlayerID'] = id,
                ['character'] = character,
                ['create'] = true
            })
        end
    end)
end

function CharacterPick:TestMapPickHero(heroReal, pickHero)
    Debug('CharacterPick', 'Picking '..pickHero)
    
    -- This gets purged after the first create...
    local id = heroReal:GetPlayerOwnerID()
    
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(id), 'character_picked', {})
    
    -- PlayerResource Replace/Select is not available quite yet...
    Timers:CreateTimer(0.01, function()
        CharacterPick:CreateCustomHeroForPlayer({
            ['PlayerID'] = id,
            ['character'] = pickHero,
            ['create'] = false
        })
    end)
end

function CharacterPick:OnCharacterPick(event)
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    if hero:GetName() ~= DUMMY_HERO then Debug('CharacterPick', 'Already selected hero...') return end
    
    -- Sound + Music for Standard Game Pick
    EmitSoundOnClient('HeroPicker.Selected', PlayerResource:GetPlayer(event.PlayerID))
    GameRules:GetGameModeEntity():EmitSound('jboberg_01.music.ui_hero_select')
    
    CharacterPick:CreateCustomHeroForPlayer(event)
end

function CharacterPick:CreateCustomHeroForPlayer(event)
    local hero
    local heroName = 'npc_dota_hero_'..event.character
    if event.create then
        Debug('CharacterPick', 'Create Hero', heroName)
        local player = PlayerResource:GetPlayer(event.PlayerID)
        hero = CreateHeroForPlayer(heroName, player)
        hero:SetControllableByPlayer(event.PlayerID, false)
        -- hero:SetOwner(player)
    else
        Debug('CharacterPick', 'Replace Hero', heroName)
        PlayerResource:ReplaceHeroWith(event.PlayerID, heroName, 0, 0)
        hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    end
    
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
            'models/heroes/invoker/invoker_head.vmdl',
            
            -- Hair/Hat
            --'models/heroes/invoker/invoker_hair.vmdl',
            --'models/items/invoker/sinisterlightning_head_s1/sinisterlightning_head_s1.vmdl',
            'models/items/invoker/sempiternal_revelations_hat_s1/sempiternal_revelations_hat_s1.vmdl',
            
            
            -- Garbs of the eastern range look pretty low key...
            -- Might be tier 1...
            
            
            -- Minor Sholders
            --'models/items/invoker/pads_of_the_eastern_range/pads_of_the_eastern_range.vmdl',
            
            -- Cape
            --'models/items/invoker/arsenal_magus_wex_cape/arsenal_magus_wex_cape.vmdl',
            
            -- Bottom/Belt/Dress
            'models/items/invoker/arsenal_magus_belt/arsenal_magus_belt.vmdl',
            
        },
        dragon_knight = {
            -- DK = Fire Tribunal Set
            
            -- Chest
            'models/items/dragon_knight/fire_tribunal_tabard/fire_tribunal_tabard.vmdl',
            
            -- Helm
            'models/items/dragon_knight/fire_tribunal_helm/fire_tribunal_helm.vmdl',
            
            -- Arms
            'models/items/dragon_knight/fire_tribunal_arms/fire_tribunal_arms.vmdl',
            
            -- Sword
            'models/items/dragon_knight/sword_of_the_drake/sword_of_the_drake.vmdl', -- Tier 1
            --'models/heroes/dragon_knight/weapon.vmdl', -- Tier 2
            --'models/items/dragon_knight/fire_tribunal_sword/fire_tribunal_sword.vmdl',
            --'models/items/dragon_knight/weapon_dragonmaw.vmdl',
            --'models/items/dragon_knight/wurmblood_weapon/wurmblood_weapon.vmdl', -- Lance
            
            -- But, weaker shield. (Maybe wyrm shield of uldorak)
            -- Shield
            'models/items/dragon_knight/shield_timedragon.vmdl',
        },
        windrunner = {
            'models/items/windrunner/ti6_windranger_back/ti6_windranger_back.vmdl',
            --'models/items/windrunner/ti6_windranger_head/ti6_windranger_head.vmdl',
            'models/items/windrunner/deadly_feather_swing_head/deadly_feather_swing_head.vmdl',
            'models/items/windrunner/ti6_windranger_shoulder/ti6_windranger_shoulder.vmdl',
            
            'models/items/windrunner/the_swift_pathfinder_swift_pathfinders_bow/the_swift_pathfinder_swift_pathfinders_bow.vmdl',
            'models/items/windrunner/ti6_windranger_offhand/ti6_windranger_offhand.vmdl',
        },
        warlock = {
            -- Helm
            'models/items/warlock/tevent_2_gatekeeper_head/tevent_2_gatekeeper_head.vmdl',
            
            -- Robes
            'models/items/warlock/archivists_robe/archivists_robe.vmdl',
            
            -- Staff
            'models/items/warlock/staff_of_infernal_chaos/staff_of_infernal_chaos.vmdl',
            
            -- Offhand
            'models/heroes/warlock/warlock_lantern.vmdl',
        }
    }
    if cosmetics[event.character] then
        -- local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
        for _,name in pairs(cosmetics[event.character]) do
            CharacterPick:AddCosmetic(hero, name)
        end
    end
    
    if event.character == 'windrunner' then
        local particleName = 'particles/units/heroes/hero_windrunner/windrunner_bowstring.vpcf'
        local idx = ParticleManager:CreateParticle(
            particleName,
            PATTACH_POINT_FOLLOW,
            hero
        )
        ParticleManager:SetParticleControlEnt(idx, 0, hero, PATTACH_POINT_FOLLOW, 'bow_bot', hero:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(idx, 1, hero, PATTACH_POINT_FOLLOW, 'bow_mid', hero:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(idx, 2, hero, PATTACH_POINT_FOLLOW, 'bow_top', hero:GetAbsOrigin(), true)
        
        -- ParticleManager:ReleaseParticleIndex(idx)
    end
    
    -- Load Data
    if not DEBUG_SKIP_HTTP_LOAD then
        Http:Load({
            steamId64 = tostring(PlayerResource:GetSteamID(event.PlayerID)),
            hero = hero:GetName(),
        }, function(data)
            Debug('CharacterPick', 'Player Loaded')
            DeepPrintTable(data)
            if data.experience then
                local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
                hero.isInitialLevel = true
                hero:AddExperience(data.experience, 0, false, false)
                hero.isInitialLevel = nil
            end
        end)
    end
    
    Event:Trigger('HeroPick', {
        hero = hero,
        PlayerID = event.PlayerID
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
end

LinkLuaModifier('character_vision', 'app/systems/characters/modifiers/character_vision', LUA_MODIFIER_MOTION_NONE)
