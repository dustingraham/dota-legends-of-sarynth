---
--@type CustomMap
CustomMap = CustomMap or {}

function CustomMap:Activate()
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(CustomMap, 'OnNpcSpawned'), self)

    Event:Listen('OnStateGameSetup', Dynamic_Wrap(CustomMap, 'OnStateGameSetup'), CustomMap)
    Event:Listen('OnStateInGame', Dynamic_Wrap(CustomMap, 'OnStateInGame'), CustomMap)
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
end

if not CustomMap.initialized then
    CustomMap.initialized = true
    Event:Listen('Activate', Dynamic_Wrap(CustomMap, 'Activate'), CustomMap)
end
