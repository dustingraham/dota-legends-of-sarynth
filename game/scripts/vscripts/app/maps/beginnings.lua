---
--@type CustomMap
CustomMap = CustomMap or {}

function CustomMap:Activate()
    Event:Listen('OnStateGameSetup', Dynamic_Wrap(CustomMap, 'OnStateGameSetup'), CustomMap)
    Event:Listen('OnStateInGame', Dynamic_Wrap(CustomMap, 'OnStateInGame'), CustomMap)
    Event:Listen('HeroPick', Dynamic_Wrap(CustomMap, 'OnHeroPick'), CustomMap)
end


function CustomMap:OnStateGameSetup()
    Debug('CustomMap', 'Beginnings Setup')
end

function CustomMap:OnStateInGame()
    Debug('CustomMap', 'Beginnings In Game')
    
    -- Timers:CreateTimer(function()
    --     print('GarbageCollect: ', collectgarbage("count"))
    --     return 1
    -- end)
    
    -- So we can auto-pick...
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(CustomMap, 'OnNpcSpawned'), self)
end

function CustomMap:OnNpcSpawned(event)
    local npc = EntIndexToHScript(event.entindex)
    if npc:IsRealHero() and npc.bFirstSpawned == nil then
        Debug('CustomMap', 'OnNpcSpawned FirstSpawn', npc:GetUnitName())
        npc.bFirstSpawned = true
        if not Boot.allPick then
            Boot.allPick = true
            if TEST_PICK_HERO then
                CharacterPick:TestMapPickHero(npc, TEST_PICK_HERO)
            end
        end
    end
end

function CustomMap:OnHeroPick(_, params)
    local hero = params.hero
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
    if TEST_SUPERMAN then
        hero:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
        hero:SetBaseMoveSpeed(3000)
        hero:SetBaseStrength(1500)
        hero:SetBaseAgility(600)
        hero:SetBaseIntellect(1500)
        hero:CalculateStatBonus()
    end
    -- hero:SetAbsOrigin(Entities:FindByName(nil, 'start_area_barricade_relay_on'):GetAbsOrigin())
end

if not CustomMap.initialized then
    CustomMap.initialized = true
    Event:Listen('Activate', Dynamic_Wrap(CustomMap, 'Activate'), CustomMap)
end

--local pos = Entities:FindByName(nil, 'teleport_tower_kobolds')
--print(pos)
--pos = pos:GetAbsOrigin()
--print(pos)
--local entity = CreateUnitByName('teleport_pad', pos, true, nil, nil, DOTA_TEAM_GOODGUYS)
