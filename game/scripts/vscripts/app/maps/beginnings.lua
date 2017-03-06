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
