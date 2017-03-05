---
--@type PlayerService
PlayerService = PlayerService or class({}, {
    players = {}
})

function PlayerService:Init()
    -- ListenToGameEvent('player_connect_full', Dynamic_Wrap(PlayerService, 'OnConnectFull'), PlayerService)
    -- Debug('PlayerService', 'Listening')
end

function PlayerService:OnConnectFull(event)
    Debug('PlayerService', 'OnConnectFull')
    self.players[event.PlayerID] = Player(event.PlayerID)
end

function PlayerService:Set(pid, key, value)
    -- Not Currently Used/Implemented
    self.players[pid]:Set(key, value)
end
