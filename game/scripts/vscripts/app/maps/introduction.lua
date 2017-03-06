---
--@type CustomMap
CustomMap = CustomMap or {}

function CustomMap:Activate()
    Event:Listen('OnStateGameSetup', Dynamic_Wrap(CustomMap, 'OnStateGameSetup'), CustomMap)
    Event:Listen('OnStateInGame', Dynamic_Wrap(CustomMap, 'OnStateInGame'), CustomMap)
end

function CustomMap:OnStateGameSetup()
    Debug('CustomMap', 'Introduction Setup')
    
--    Reporter:Init()
end

function CustomMap:OnStateInGame()
    Debug('CustomMap', 'Introduction In Game')
    
    -- All players have loaded. Play a noise, and start some spawning while they pick.
    EmitGlobalSound('Hero_Omniknight.Pick')
end

if not CustomMap.initialized then
    CustomMap.initialized = true
    Event:Listen('Activate', Dynamic_Wrap(CustomMap, 'Activate'), CustomMap)
end
