---
--@type PlayerService
PlayerService = PlayerService or class({}, {
    players = {}
})

function PlayerService:Activate()
    ListenToGameEvent('player_connect_full', Dynamic_Wrap(PlayerService, 'OnConnectFull'), PlayerService)
    Debug('PlayerService', 'Listening')
end

function PlayerService:OnConnectFull(event)
    Debug('PlayerService', 'OnConnectFull')
    self.players[event.PlayerID] = Player(event.PlayerID)
end

function PlayerService:Set(pid, key, value)
    -- Not Currently Used/Implemented
    self.players[pid]:Set(key, value)
end

if not PlayerService.initialized then
    PlayerService.initialized = true
    Event:Listen('Activate', Dynamic_Wrap(PlayerService, 'Activate'), PlayerService)
end
