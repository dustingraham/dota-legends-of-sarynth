---
-- Mainly for the table
--
--@type Player
Player = Player or class({
    gametime = 0,
    experience = 0
})

local translateCharacterToHeroName = {
    Warrior = 'dragon_knight',
    Paladin = 'omniknight',
    Rogue = 'bounty_hunter',
    Ranger = 'windrunner',
    Mage = 'invoker',
    Sorcerer = 'warlock'
}

function Player:constructor(PlayerID)
    self.PlayerID = PlayerID

    --Create a Table and set a few values.
    PlayerTables:CreateOrSubscribe('player_'..PlayerID..'_quests', {}, {PlayerID})
    PlayerTables:CreateOrSubscribe('player_'..PlayerID..'_characters', {}, {PlayerID})

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

function Player:SetCurrentSlot(slotId)
    self.slot_id = slotId
end

function Player:GetSlotId()
    return self.slot_id
end

function Player:SetCharacter(character)
    self.character = character
end

function Player:GetCharacter()
    return self.character
end

function Player:GetCharacterHeroName()
    return translateCharacterToHeroName[self:GetCharacter()]
end

function Player:GetPriorGametime()
    return self.gametime
end

function Player:GetPriorGold()
    return self.gold
end
function Player:GetPriorExperience()
    return self.experience
end
function Player:GetPriorItems()
    return self.items
end
function Player:GetPriorZone()
    return self.zone
end
function Player:GetPriorQuests()
    return self.quests
end
function Player:LoadSlot(slotId)
    local key = 'player_'..self.PlayerID..'_characters'
    for _,data in pairs(PlayerTables:GetAllTableValues(key)) do
        if data.slot_id == slotId then
            self:SetCurrentSlot(slotId)
            self:LoadSlotData(data)
            return
        end
    end
    error('Attribute not found: slot_id [in character data]')
end

function Player:LoadSlotData(data)
    -- Merge in selected data.
    TableMerge(self, data)
end

function Player:Save()
    if self.slot_id == nil then error('SlotID expected to be set.') end
    SaveLoad:CreateCharacter(self)
end

function Player:Load()
    SaveLoad:FetchCharacters(self, function(data)
        local key = 'player_'..self.PlayerID..'_characters'
        -- DeepPrintTable(data)
        PlayerTables:SetTableValues(key, data)
    end)
end
