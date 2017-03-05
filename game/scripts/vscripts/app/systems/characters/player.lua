---
-- Mainly for the table
-- 
--@type Player
Player = Player or class({})

function Player:constructor(PlayerID)
    self.PlayerID = PlayerID
    
    --Create a Table and set a few values.
    PlayerTables:CreateTable('player_'..PlayerID..'_quests', {}, {PlayerID})
    
    -- PlayerTables:SetTableValue("player_0_quests", "count", 0)
    -- PlayerTables:SetTableValues("player_0_quests", {val1=1, val2=2})
    
    
    -- PlayerTables:SetTableValues('player_0_quests', 'quests', {})
end

function Player:Set(key, value)
    --PlayerTables:SetTableValue('player_0_quests', key, value)
end

-- PlayerTables:SetTableValue('player_0_quests', 'first', {
--     title = 'Kill rats',
--     current = 6,
--     required = 6
-- })

-- PlayerTables:DeleteTableKey('player_0_quests', 'first')

-- PlayerTables:DeleteTableKey('player_0_quests', 'second')
