---
--@type CustomMap
CustomMap = CustomMap or {}

function CustomMap:Activate()
    Event:Listen('OnStateGameSetup', Dynamic_Wrap(CustomMap, 'OnStateGameSetup'), CustomMap)
    Event:Listen('OnStateInGame', Dynamic_Wrap(CustomMap, 'OnStateInGame'), CustomMap)
end


function CustomMap:OnStateGameSetup()
    Debug('CustomMap', 'Beginnings Setup')
end

function CustomMap:OnStateInGame()
    Debug('CustomMap', 'Beginnings In Game')
    
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
            CharacterPick:TestMapPickGondar(npc)
        end
    end
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
