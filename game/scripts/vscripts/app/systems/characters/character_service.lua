---
--@type CharacterService
CharacterService = CharacterService or class({})
--[[

    This is probably a bad class, but for now, putting this here...

]]
function CharacterService:Activate()
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(CharacterService, 'OnNPCSpawned'), self)
    ListenToGameEvent('entity_killed', Dynamic_Wrap(CharacterService, 'OnEntityKilled'), self)
    ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(CharacterService, 'OnPlayerLevelUp'), self)
    ListenToGameEvent('entity_hurt', Dynamic_Wrap(CharacterService, 'OnEntityHurt'), self)

    CustomGameEventManager:RegisterListener('inventory_open', Dynamic_Wrap(CharacterService, 'OnInventoryOpen'))
    CustomGameEventManager:RegisterListener('inventory_close', Dynamic_Wrap(CharacterService, 'OnInventoryClose'))
    CustomGameEventManager:RegisterListener('inventory_toggle', Dynamic_Wrap(CharacterService, 'OnInventoryToggle'))

    -- Boot.mode:SetModifyExperienceFilter(Dynamic_Wrap(CharacterService, 'ExperienceFilter'), CharacterService)
    Filters:OnModifyExperienceFilter(Dynamic_Wrap(CharacterService, 'ExperienceFilter'), CharacterService)

    Event:Listen('HeroItemAcquire', Dynamic_Wrap(CharacterService, 'OnHeroItemAcquire'), CharacterService)
    Event:Listen('HeroPick', Dynamic_Wrap(CharacterService, 'OnHeroPick'), CharacterService)
    Event:Listen('HeroDeath', Dynamic_Wrap(CharacterService, 'OnHeroDeath'), CharacterService)
end

function CharacterService:OnNPCSpawned(event)
    local npc = EntIndexToHScript(event.entindex)
    if npc:IsRealHero() and npc:GetName() == DUMMY_HERO then
        npc:AddNoDraw()
        npc:AddNewModifier(npc, nil, 'character_hidden', {})
    end
end

-- Combo Functions to display exp overhead.
function CharacterService:OnEntityHurt(event)
    if not event.entindex_attacker then return end
    local attacker = EntIndexToHScript(event.entindex_attacker);

    -- IsRealHero to ignore illusions.
    if not attacker:IsHero() then return end

    local npc = EntIndexToHScript(event.entindex_killed);

    if not npc.originalExp then
        npc.originalExp = npc:GetDeathXP()
        npc.expModifier = 1.00
    end

    local scale = {
        [-3] = 1.50,
        [-2] = 1.25,
        [-1] = 1.10,
        [0] = 1.00,
        [1] = 0.50,
        [2] = 0.25,
        [3] = 0.10,
        [4] = 0.00
    }
    local modifier = scale[Clamp(attacker:GetLevel() - npc:GetLevel(), -3, 4)]

    if npc.expModifier ~= modifier then
        -- Debug('CharacterService', 'Exp Modifier: ', modifier)
        npc.expModifier = modifier
        npc:SetDeathXP(npc.originalExp * modifier)
    end

    -- This might be troublesome...
    attacker.lastAttacked = npc
end
function CharacterService:ExperienceFilter(e, params)
--    Debug('CharacterService', 'OnExperienceFilter')
--    print(inspect(params))
    
    local player = PlayerResource:GetPlayer( params.player_id_const )
    local hero = PlayerResource:GetSelectedHeroEntity(params.player_id_const)

    -- This might be troublesome...
    local npc = hero.lastAttacked

    -- If Setting...
    SendOverheadEventMessage( player, OVERHEAD_ALERT_XP , npc, params.experience, nil )

    return true
end

-- Compute experience needed for next level, and notify player
function CharacterService:OnEntityKilled(event)
    local killed = EntIndexToHScript(event.entindex_killed);
    local attacker = nil
    if event.entindex_attacker ~= nil then
        attacker = EntIndexToHScript(event.entindex_attacker);
    end

    if killed:IsRealHero() then
        -- Bug, neutral kill.
        killed:SetTimeUntilRespawn(5)
        Event:Trigger('HeroDeath', {
            hero = killed,
            killer = attacker,
        })
    end

    -- IsRealHero to ignore illusions.
    if attacker and attacker:IsHero() then
        Event:Trigger('HeroKilledCreature', {
            hero = attacker,
            creature = killed,
        })
    end
end

function CharacterService:OnHeroDeath(e, event)
    print(event.hero:GetName())
end

function CharacterService:OnPlayerLevelUp(event)
    local hero = HeroList:GetHero(event.player)
    hero:SetAbilityPoints(0)
    
    for i = 0, 2 do
        -- Temp Spell Levels
        -- 0 : 1 4 7 10
        -- 1 : 2 5 8 11
        -- 2 : 3 6 9 12
        hero:GetAbilityByIndex(i):SetLevel(
            math.min(3, math.floor((event.level + 2- i) / 3))
        )
    end
    
    if hero.isInitialLevel then return end
    
    -- Slightly better level up particle...
    local pIdx = ParticleManager:CreateParticle("particles/econ/events/ti6/hero_levelup_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
    ParticleManager:SetParticleControl(pIdx, 0, hero:GetAbsOrigin())
    
    if not DEBUG_SKIP_HTTP_SAVE then
        Debug('CharacterService', 'Saving for: ', hero:GetName())
        Http:Save({
            steamId64 = tostring(PlayerResource:GetSteamID(hero:GetPlayerOwnerID())),
            hero = hero:GetName(),
            experience = hero:GetCurrentXP(),
        }, function(data)
            Debug('CharacterService', 'Successfully saved!')
        end)
    end

    Event:Trigger('HeroLevelUp', {
        hero = hero
    })
end


local function TestItem(pos, key)
    local item = CreateItem(key, nil, nil)
    local drop = CreateItemOnPositionSync(pos, item)
    local pos_launch = pos + RandomVector(RandomFloat(150, 200))
    item:LaunchLoot(false, 200, 0.75, pos_launch)
end
local function TestTest(hero)
    local pos = hero:GetAbsOrigin()
    TestItem(pos, 'item_broadsword_tier1')
    TestItem(pos, 'item_broadsword_tier2')
    TestItem(pos, 'item_broadsword_tier3')
    TestItem(pos, 'item_broadsword_tier4')
    TestItem(pos, 'item_armor_tier1')
    TestItem(pos, 'item_armor_tier2')
    TestItem(pos, 'item_armor_tier3')
    TestItem(pos, 'item_amulet_tier1')
    TestItem(pos, 'item_amulet_tier2')
    TestItem(pos, 'item_amulet_tier3')
    TestItem(pos, 'item_boots_leather')
    TestItem(pos, 'item_boots_leather_common')
end

function CharacterService:OnHeroPick(e, event)
    local hero = event.hero
    hero.customInventory = Containers:CreateContainer({
        -- layout = {6,6,6},
        layout = {4,4,4,4,4},
        position = "220px 120px 0px",
        entity = hero,
        headerText = "#Container_Backpack",
        pids = {0}, -- tood Dynamic to hero
        OnDragWorld = true,
        AddItemFilter = Dynamic_Wrap(CharacterService, 'ContainerItemFilter'),
    })
    hero.customEquipment = Containers:CreateContainer({
        layout = {2,2,2},
        position = "20px 120px 0px",
        entity = hero,
        headerText = "#Container_Equipment",
        pids = {0}, -- tood Dynamic to hero
        OnDragWorld = true,
        equipment = true,
        AddItemFilter = Dynamic_Wrap(CharacterService, 'ContainerItemFilter'),
    })
    hero.customEquipment:Open(0)
    Containers:SetDefaultInventory(hero, hero.customInventory)
    
    -- Items for testing.
    if IsInToolsMode() and TEST_SPAWN_ITEMS then TestTest(hero) end
end

function CharacterService:ContainerItemFilter(item, slot)
    -- self == container
    if not item.alreadyKnown then
        item.alreadyKnown = true

        Event:Trigger('HeroItemAcquire', {
            hero = self:GetEntity(),
            item = item,
        })
    end
    return true
end

function CharacterService:OnInventoryOpen(event)
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    -- This is actually a toggle...
    local c = hero.customInventory
    if c:IsOpen(event.PlayerID) then
        c:Close(event.PlayerID)
    else
        c:Open(event.PlayerID)
        c.hasOpened = true
    end
end

function CharacterService:OnInventoryClose(event)
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    local c = hero.customInventory
    if c:IsOpen(event.PlayerID) then
        c:Close(event.PlayerID)
    end
end

function CharacterService:OnInventoryToggle(event)
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    local c = hero[event.container]
    if c:IsOpen(event.PlayerID) then
        c:Close(event.PlayerID)
    else
        c:Open(event.PlayerID)
        c.hasOpened = true
    end
end

function CharacterService:OnHeroItemAcquire(e, event)
    local hero = event.hero
    -- This is actually a toggle...
    local c = event.hero.customInventory
    if not c.hasOpened then
        c:Open(event.hero:GetPlayerOwnerID())
        c.hasOpened = true
    end
end

if not CharacterService.initialized then
    CharacterService.initialized = true
    Event:Listen('Activate', Dynamic_Wrap(CharacterService, 'Activate'), CharacterService)
end

LinkLuaModifier('character_hidden', 'app/systems/characters/modifiers/character_hidden', LUA_MODIFIER_MOTION_NONE)
