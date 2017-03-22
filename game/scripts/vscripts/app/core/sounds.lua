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
        print('ERROR - Sounds : No player with ID', playerID)
    end
    return false
end
