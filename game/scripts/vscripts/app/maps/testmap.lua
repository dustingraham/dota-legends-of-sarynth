CustomMap = CustomMap or {}

function CustomMap:Activate()
    Event:Listen('OnStateGameSetup', Dynamic_Wrap(CustomMap, 'OnStateGameSetup'), CustomMap)
    Event:Listen('OnStateInGame', Dynamic_Wrap(CustomMap, 'OnStateInGame'), CustomMap)
end


function CustomMap:OnStateGameSetup()
    Debug('CustomMap', 'Test Map Setup')
end

function CustomMap:OnStateInGame()
    Debug('CustomMap', 'Test Map In Game')
    
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
--            CharacterPick:TestMapPickAll(npc)
        end
    end
end
