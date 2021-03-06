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

function CharacterService:GetExperienceLevelRequirements()
    -- 0, 100, 300, 600, 1000,
    -- 1500, 2100, 2800, 3600, 4500
    -- 5500, 6600, 7800, 9100, 10500
    -- 12000, 13600, 15300, 17100, 19000
    -- L25: 34500
    -- L30: 60000
    local table = {}
    for i = 1, 28 do
        table[i] = 100 * (i - 1) + 50 * ((i - 1) * (i - 2))
        if i > 20 then table[i] = table[i] + (i - 19)*(i - 20) * 150 end
    end
    return table
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
end

function CharacterService:ExperienceFilter(e, params)
    local hero = PlayerResource:GetSelectedHeroEntity(params.player_id_const)

    -- Difficult to track where this EXP came from. Might have come from a
    -- target that an ally killed, which this hero doesn't know about.
    -- So, we'll just show the +exp over the hero itself. Seems to make sense
    -- anyways.
    -- SendOverheadEventMessage( player, OVERHEAD_ALERT_XP , hero, params.experience, nil )
    if params.experience > 0 then
        PopupExperience(hero, params.experience)
    end

    return true
end

-- Compute experience needed for next level, and notify player
function CharacterService:OnEntityKilled(event)
    local killed = EntIndexToHScript(event.entindex_killed);
    local attacker
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
    local hero = event.hero
    Debug('CharacterService', 'OnHeroDeath', hero:GetName())

    -- Find closest respawn point.
    if hero.currentZone then
        local point = Entities:FindByName(nil, hero.currentZone..'_spawn_point')
        if point then
            hero:SetRespawnPosition(point:GetAbsOrigin())
        end
    end

    -- Clear focus target
    FocusTarget:ClearFocusTarget(hero:GetPlayerOwnerID())

    -- FindPathLength appears broken above 2000 distance.
    --local closestDistance
    --local closestPoint
    --local deathPoint = event.hero:GetAbsOrigin()
    --for _,point in pairs(Entities:FindAllByName('respawn_option')) do
    --    local distance = GridNav:FindPathLength(point:GetAbsOrigin(), deathPoint)
    --    if distance ~= -1 then
    --        print('-----------')
    --        print('CanFind: ', GridNav:CanFindPath(point:GetAbsOrigin(), deathPoint))
    --        print('GridNav: ', distance)
    --        print('Point: ', point:GetAbsOrigin())
    --        print('Death: ', deathPoint)
    --        print('Straight: ', (point:GetAbsOrigin() - deathPoint):Length())
    --
    --        if closestDistance == nil or distance < closestDistance then
    --            print('Picking: ', distance)
    --            closestDistance = distance
    --            closestPoint = point
    --        end
    --    end
    --end
    --print('Picked: ', closestDistance)
    --event.hero:SetRespawnPosition(closestPoint:GetAbsOrigin())
end

function CharacterService:OnPlayerLevelUp(event)
    --DeepPrintTable(event)
    local player = EntIndexToHScript(event.player)
    local hero = player:GetAssignedHero()
    if not hero then return end

    hero:SetAbilityPoints(0)

    --    for i = 0, 2 do
    --        -- Temp Spell Levels
    --        -- 0 : 1 4 7 10
    --        -- 1 : 2 5 8 11
    --        -- 2 : 3 6 9 12
    --        hero:GetAbilityByIndex(i):SetLevel(
    --            math.min(3, math.floor((event.level + 2- i) / 3))
    --        )
    --    end

    if hero.isInitialLevel then return end

    -- Slightly better level up particle...
    local pIdx = ParticleManager:CreateParticle("particles/econ/events/ti6/hero_levelup_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
    ParticleManager:SetParticleControl(pIdx, 0, hero:GetAbsOrigin())

    Notifications:Top(hero:GetPlayerOwnerID(), {
        text = "You just reached level "..event.level.."!",
        duration = 6,
        style = { color = "#ffcc00" }
    })

    Event:Trigger('HeroLevelUp', {
        hero = hero
    })
end

function CharacterService:OnHeroPick(e, event)
    local hero = event.hero

    -- Create Inventory
    hero.inventory = Inventory(hero)

    -- Load Items Equipment/Inventory
    local items = event.player:GetPriorItems()
    if items then
        if items.equipment then
            -- Old style.
            Debug('CharacterService', 'Loading old item style.')
            for _,itemDef in pairs(items.equipment) do
                hero.inventory:CreateItem(itemDef.name)
            end
            for _,itemDef in pairs(items.inventory) do
                hero.inventory:CreateItem(itemDef.name)
            end
        else
            -- New style.
            Debug('CharacterService', 'Loading new item style.')
            for slotId,itemName in pairs(items) do
                hero.inventory:CreateItem(itemName, slotId)
            end
        end
    end

    -- Items for testing.
    if IsInToolsMode() and TEST_SPAWN_ITEMS and TEST_EQUIP_ITEMS then
        for slotId,itemName in pairs(TEST_EQUIP_ITEMS) do
            hero.inventory:CreateItem(itemName, slotId)
        end
    end
    if IsInToolsMode() and TEST_SPAWN_ITEMS and TEST_ADD_ITEMS then
        for _,itemName in pairs(TEST_ADD_ITEMS) do
            hero.inventory:CreateItem(itemName)
        end
    end
    --TestQuest(hero)
end

if not CharacterService.initialized then
    CharacterService.initialized = true
    Event:Listen('Activate', Dynamic_Wrap(CharacterService, 'Activate'), CharacterService)
end

LinkLuaModifier('character_hidden', 'app/systems/characters/modifiers/character_hidden', LUA_MODIFIER_MOTION_NONE)
