
local ResolveItem = function(item)
    if type(item) == 'number' then
        return EntIndexToHScript(item)
    end
    if item and IsValidEntity(item) and item.IsItem and item:IsItem() then
        return item
    end
    return nil
end

---
--@type Inventory
Inventory = Inventory or class({
    backpack = {},
    equipment = {},
    items = {},
    itemNames = {}
})

function Inventory:constructor(hero)
    self.hero = hero
    self.tableName = 'player_items_'..hero:GetPlayerOwnerID()
    PlayerTables:CreateTable(self.tableName, {}, {hero:GetPlayerOwnerID()})
    print('Created: ', self.tableName)
end

function Inventory:AddItem(item)
    item = ResolveItem(item)

    local itemid = item:GetEntityIndex()
    local itemname = item:GetAbilityName()

    -- Straight add item will go to backpack.
    -- Start looking at 11
    -- Find a place and place it
    for i = 11, 46 do
        if not self:IsItemInSlot(i) then
            self.items[itemid] = i
            self.itemNames[itemname] = self.itemNames[itemname] or {}
            self.itemNames[itemname][itemid] = i

            -- Dunno if necessary
            item:SetOwner(self.hero)
            -- ApplyPassives(self, item)

            -- Notify client
            PlayerTables:SetTableValue(self.tableName, 'slot'..i, itemid)
            return true
        end
    end
    -- Bad...
    return false
end

function Inventory:IsItemInSlot(i)
    -- Shouldn't we just pull it from a local table...?
    local item = PlayerTables:GetTableValue(self.tableName, 'slot'..i)
    if item then
        item = ResolveItem(item)
        if item and not IsValidEntity(item) then
            print('Item became invalid...?')
            PlayerTables:DeleteTableKey(self.tableName, 'slot'..i)
            return false
        end
        if item and IsValidEntity(item) and item.IsItem and item:IsItem() then
            return true
        end
        print('Found something, but not invalid, but not item...?')
    end
    return false
end
