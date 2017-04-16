---
--@type SaveLoad
SaveLoad = SaveLoad or class({})

function SaveLoad:CreateCharacter(player)
    Http:Send('/api/save/create', {
        steamId64 = tostring(PlayerResource:GetSteamID(player.PlayerID)),
        data = {
            slotId = player:GetSlotId(),
            character = player:GetCharacter()
        }
    }, function(data)
        Debug('Http', 'Saved initial character create.')
    end)
end

function SaveLoad:FetchCharacters(player, callback)
    Http:Send('/api/load/characters', {
        steamId64 = tostring(PlayerResource:GetSteamID(player.PlayerID))
    }, callback)
end
