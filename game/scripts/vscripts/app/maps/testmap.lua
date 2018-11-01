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
    Debug('CustomMap', 'Test Map Setup')
end

function CustomMap:OnStateInGame()
    Debug('CustomMap', 'Test Map In Game')
end

function CustomMap:OnNpcSpawned(event)
    local npc = EntIndexToHScript(event.entindex)
    if npc:IsRealHero() and npc.bFirstSpawned == nil then
        Debug('CustomMap', 'OnNpcSpawned FirstSpawn', npc:GetUnitName())
        npc.bFirstSpawned = true
        if not Boot.allPick then
            Boot.allPick = true
            -- CharacterPick:TestMapPickAll(npc)
            if not TEST_PICK_HERO then
                TEST_PICK_HERO = 'windrunner'
            end
            CharacterPick:TestMapPickHero(npc, TEST_PICK_HERO)
        end
    end
    npc:SetControllableByPlayer(0, false)
end

function CustomMap:OnHeroPick(_, params)
    local hero = params.hero
    if DEBUG_SETTINGS then
        hero:AddNewModifier(hero, nil, 'character_testmode', nil)
    end
    if TEST_START_LEVEL then
        hero.isInitialLevel = true
        local expTable = CharacterService:GetExperienceLevelRequirements()
        local expNeeded = expTable[TEST_START_LEVEL]
        hero:AddExperience(expNeeded, 0, false, false)
        hero.isInitialLevel = nil
    end
    if TEST_SUPERPATHEY then
        hero:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
        hero:SetBaseMoveSpeed(TEST_SUPERPATHEY)
    end
    if TEST_SUPERSTRONG then
        hero:SetBaseStrength(1500)
        hero:SetBaseAgility(600)
        hero:SetBaseIntellect(1500)
        hero:CalculateStatBonus()
    end
end

function CustomMap:OnScriptReload()
    print('Reload...')

    --local units = FindUnitsInRadius(
    --DOTA_TEAM_GOODGUYS, nil, nil,
    --self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE,
    --FIND_ANY_ORDER, false
    --)

    for _,unit in pairs(FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                                          Vector(0, 0, 0),
                                          nil,
                                          FIND_UNITS_EVERYWHERE,
                                          DOTA_UNIT_TARGET_TEAM_ENEMY,
                                          DOTA_UNIT_TARGET_ALL,
                                          DOTA_UNIT_TARGET_FLAG_NONE,
                                          FIND_ANY_ORDER,
                                          false)) do
        unit:ForceKill(false)
    end

end

if not CustomMap.initialized then
    CustomMap.initialized = true
    Event:Listen('Activate', Dynamic_Wrap(CustomMap, 'Activate'), CustomMap)
else
    CustomMap:OnScriptReload()
end

