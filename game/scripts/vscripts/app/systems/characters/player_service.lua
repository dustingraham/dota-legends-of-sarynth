---
--@type PlayerService
PlayerService = PlayerService or class({}, {
    players = {}
})

function PlayerService:Activate()
    ListenToGameEvent('player_connect_full', Dynamic_Wrap(PlayerService, 'OnConnectFull'), PlayerService)
    CustomGameEventManager:RegisterListener('settings_focus_target', Dynamic_Wrap(PlayerService, 'OnSettingsFocusTarget', PlayerService))
    Debug('PlayerService', 'Listening')
end

function PlayerService:OnConnectFull(event)
    Debug('PlayerService', 'OnConnectFull')
    DeepPrintTable(event)

    -- TODO: Recall setting.
    Wrappers.ToggleFocusTargetUsage(event.PlayerID, 1)

    self.players[event.PlayerID] = Player(event.PlayerID)
end

function PlayerService:Set(pid, key, value)
    -- Not Currently Used/Implemented
    self.players[pid]:Set(key, value)
end

function PlayerService:OnSettingsFocusTarget(event)
    -- TODO: Store setting.
    Wrappers.ToggleFocusTargetUsage(event.PlayerID, event.value)
end

Event:BindActivate(PlayerService)
