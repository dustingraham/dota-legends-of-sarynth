---
--@type CustomMap
CustomMap = CustomMap or {}

function CustomMap:Activate()
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(CustomMap, 'OnNpcSpawned'), self)

    Event:Listen('OnStateGameSetup', Dynamic_Wrap(CustomMap, 'OnStateGameSetup'), CustomMap)
    Event:Listen('OnStateInGame', Dynamic_Wrap(CustomMap, 'OnStateInGame'), CustomMap)
    Event:Listen('HeroPick', Dynamic_Wrap(CustomMap, 'OnHeroPick'), CustomMap)
end


function CustomMap:OnStateGameSetup()
    Debug('CustomMap', 'Beginnings Setup')
end

function CustomMap:OnStateInGame()
    Debug('CustomMap', 'Beginnings In Game')

    if TEST_DRUIDS_UNLOCKED then
        local unit = SpawnSystem:GetUnique('druids_tower_1')
        unit.ai.countUnlocked = 3
        local door = Entities:FindByName(nil, 'druids_building_door')
        door:SetAbsOrigin(door:GetAbsOrigin() - Vector(0,0,512))
        -- Remove the simple obstructions
        for _,obstruction in pairs(Entities:FindAllByName('druids_door_obstruction')) do
            obstruction:SetEnabled(false, false)
        end
    end
end

function CustomMap:OnNpcSpawned(event)
    local npc = EntIndexToHScript(event.entindex)
    if npc:IsRealHero() then
        -- Potential fix for auto-attack issue. Unable to reproduce.
        npc:Stop()
        if npc.bFirstSpawned == nil then
            Debug('CustomMap', 'OnNpcSpawned FirstSpawn', npc:GetUnitName())
            npc.bFirstSpawned = true
            if not Boot.allPick then
                Boot.allPick = true
                if TEST_PICK_HERO then
                    CharacterPick:TestMapPickHero(npc, TEST_PICK_HERO)
                end
                if TEST_PICK_HERO_ALT then
                    CharacterPick:CreateCustomHeroForPlayer(npc:GetPlayerOwnerID(), TEST_PICK_HERO_ALT, false)
                end
            end
        end
    end
end

function CustomMap:OnHeroPick(_, params)
    local hero = params.hero
    if DEBUG_SETTINGS then
        hero:AddNewModifier(hero, nil, 'character_testmode', nil)
    end
    if TEST_START_WAYPOINT then
        local target = SpawnSystem:GetUnique('teleport_tower_'..TEST_START_WAYPOINT)
        hero:SetAbsOrigin(target:GetAbsOrigin() +  RandomVector(120))
    end
    if TEST_START_LEVEL then
        hero.isInitialLevel = true
        local expTable = CharacterService:GetExperienceLevelRequirements()
        local expNeeded = expTable[TEST_START_LEVEL]
        hero:AddExperience(expNeeded, 0, false, false)
        hero.isInitialLevel = nil
    end
    if TEST_SUPERPATHEY then
        if TEST_SUPERPATHEY_FLIES then
            hero:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
        end
        hero:SetBaseMoveSpeed(TEST_SUPERPATHEY)
    end
    if TEST_SUPERSTRONG then
        hero:SetBaseStrength(TEST_SUPERSTR)
        hero:SetBaseAgility(TEST_SUPERAGI)
        hero:SetBaseIntellect(TEST_SUPERINT)
        hero:SetBaseDamageMin(TEST_SUPERATK)
        hero:SetBaseDamageMax(TEST_SUPERATK)
        hero:CalculateStatBonus()
    end
    if TEST_START_START_BOSS then
        hero:SetAbsOrigin(Entities:FindByName(nil, 'start_area_barricade_relay_on'):GetAbsOrigin())
    end
    if TEST_START_DARK_BOSS then
        hero:SetAbsOrigin(Entities:FindByName(nil, 'zone_dark_boss_spawn_point'):GetAbsOrigin())
    end
    if TEST_START_DRUID_BOSS then
        hero:SetAbsOrigin(Entities:FindByName(nil, 'zone_druids_boss_spawn_point'):GetAbsOrigin() + RandomVector(120))
    end
    -- Ensure moved heroes are not stuck together.
    Timers(0.25, function()
        -- Fix collision
        ResolveNPCPositions(hero:GetAbsOrigin(), 300)
    end)
end

if not CustomMap.initialized then
    CustomMap.initialized = true
    Event:Listen('Activate', Dynamic_Wrap(CustomMap, 'Activate'), CustomMap)
end

