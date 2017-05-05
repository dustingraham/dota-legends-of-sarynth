---
-- Author SheepTag
-- https://github.com/ynohtna92/SheepTag/blob/bfd56d2332e12f80a74a7ef64aec6e9e4919f339/game/dota_addons/sheeptag/scripts/vscripts/libraries/sounds.lua
Sounds = Sounds or class({})

function Sounds:EmitSoundOnClient(playerID, sound)
    local player = PlayerResource:GetPlayer(playerID)
    Debug('Sounds', 'EmitSoundOnClient', playerID, sound)

    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "emit_client_sound", { sound = sound })
        return true
    else
        Debug('Sounds', 'ERROR - Sounds : No player with ID', playerID)
    end
    return false
end

-- Mainly useful for being able to stop looping sounds.
function Sounds:Start(sound, PlayerID)
    local player = PlayerResource:GetPlayer(PlayerID)
    Debug('Sounds', 'Sounds:Start', PlayerID, sound)

    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, 'emit_client_sound_start', { sound = sound })
        return true
    else
        Debug('Sounds', 'ERROR - Sounds : No player with ID', PlayerID)
    end
    return false
end

function Sounds:Stop(sound, PlayerID)
    local player = PlayerResource:GetPlayer(PlayerID)
    Debug('Sounds', 'Sounds:Stop', PlayerID, sound)

    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, 'emit_client_sound_stop', { sound = sound })
        return true
    else
        Debug('Sounds', 'ERROR - Sounds : No player with ID', PlayerID)
    end
    return false
end
