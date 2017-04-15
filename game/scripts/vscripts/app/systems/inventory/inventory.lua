
local ResolveItem = function(item)
    if type(item) == 'number' then
        return EntIndexToHScript(item)
    end
    if item and IsValidEntity(item) and item.IsItem and item:IsItem() then
        return item
    end
    return nil
end


local applied = {}

local ApplyPassives = function(hero, item)
    -- Check if it is already applied
    if applied[item:GetEntityIndex()] then return end
    -- We may need to loop through buffs anyways to check.
    applied[item:GetEntityIndex()] = {}

    local passives = InventoryService.itemPassives[item:GetAbilityName()]
    if passives then
        for _,passive in ipairs(passives) do
            item:ApplyDataDrivenModifier(hero, hero, passive, {})
            buffs = hero:FindAllModifiersByName(passive)
            for _, buff in ipairs(buffs) do
                if buff:GetAbility() == item then
                    table.insert(applied[item:GetEntityIndex()], buff)
                    break
                end
            end
        end
    else
        passives = item:GetIntrinsicModifierName()
        if passives then
            local buff = hero:AddNewModifier(hero, item, passives, {})
            applied[item:GetEntityIndex()] = {buff}
        end
    end
end

local RemovePassives = function(hero, item)
    local eid = item:GetEntityIndex()
    local mods = applied[eid]
    if mods then
        for _, mod in ipairs(mods) do
            if not mod:IsNull() then
                mod:Destroy()
            end
        end
    end
    applied[eid] = nil
end

---
--@type Inventory
Inventory = Inventory or class({
   backpack = {},
   equipment = {},
   items = {},
   itemNames = {}
}, {
    panelSlotTypes = {
        [1] = 3, -- Helm
        [2] = 4, -- Neck
        [3] = 5, -- Chest
        -- 4 reserved sholders
        -- 5 reserved gloves
        -- 6 reserved pants
        -- 7 reserved belt
        [8] = 11, -- ring1
        [9] = 11, -- ring2
        [10] = 10, -- boots
        [11] = 1, -- weapon
        [12] = 2 -- offhand
    }
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
    -- Start looking at 13
    -- Find a place and place it
    for i = 13, 48 do
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

function Inventory:SwapSlots(fromSlotId, toSlotId)
    --print('===')
    --print(fromSlotId)
    --print(toSlotId)
    local fromItem = self:GetItemInSlot(fromSlotId)
    local toItem = self:GetItemInSlot(toSlotId)
    if fromItem and toItem then
        return self:SwapItems(fromItem, toItem)
    elseif fromItem then
        print('This should not happen...')
        local fromItemId = fromItem:GetEntityIndex()
        local fromItemName = fromItem:GetAbilityName()
        self.items[fromItemId] = toSlotId
        self.itemNames[fromItemName][fromItemId] = toSlotId
        PlayerTables:SetTableValue(self.tableName, "slot"..toSlotId, fromItemId)
        PlayerTables:DeleteTableKey(self.tableName, "slot"..fromSlotId)
    elseif toItem then
        local fromItemSlotId = tonumber(string.match(fromSlotId, "%d+"))
        local toItemSlotId = tonumber(string.match(toSlotId, "%d+"))
        local toItemId = toItem:GetEntityIndex()
        local toItemName = toItem:GetAbilityName()
        self.items[toItemId] = fromItemSlotId
        self.itemNames[toItemName][toItemId] = fromItemSlotId
        PlayerTables:SetTableValue(self.tableName, "slot"..fromItemSlotId, toItemId)
        PlayerTables:DeleteTableKey(self.tableName, "slot"..toItemSlotId)
        if toItemSlotId <= 12 then
            RemovePassives(self.hero, toItem)
        end
        if fromItemSlotId <= 12 then
            ApplyPassives(self.hero, toItem)
        end
    end
end
function Inventory:SwapItems(fromItem, toItem)
    --print(fromItem)
    --print(toItem)
    --print('---')
    local fromItemId = fromItem:GetEntityIndex()
    local fromItemName = fromItem:GetAbilityName()
    local fromItemSlotId = self.items[fromItemId]
    local toItemId = toItem:GetEntityIndex()
    local toItemName = toItem:GetAbilityName()
    local toItemSlotId = self.items[toItemId]

    -- Enforce slot restrictions
    if fromItemSlotId <= 12 then
        if not self:CheckCompatibleSlot(fromItemSlotId, toItem) then
            return false
        end
    end
    if toItemSlotId <= 12 then
        if not self:CheckCompatibleSlot(toItemSlotId, fromItem) then
            return false
        end
    end

    if toItemId and fromItemId then
        -- TODO Combine

        self.items[toItemId] = fromItemSlotId
        self.items[fromItemId] = toItemSlotId
        self.itemNames[fromItemName][fromItemId] = toItemSlotId
        self.itemNames[toItemName][toItemId] = fromItemSlotId

        if toItemSlotId <= 12 then
            RemovePassives(self.hero, toItem)
            ApplyPassives(self.hero, fromItem)
        end
        if fromItemSlotId <= 12 then
            ApplyPassives(self.hero, toItem)
            RemovePassives(self.hero, fromItem)
        end

        PlayerTables:SetTableValues(self.tableName, {
            ['slot'..fromItemSlotId] = toItemId,
            ['slot'..toItemSlotId] = fromItemId
        })
        return true
    end
    return false
end

function Inventory:CheckCompatibleSlot(slotId, item)
    return self.panelSlotTypes[slotId] ==  item:GetSpecialValueFor('slot_type')
end

function Inventory:EquipItem(item)
    item = ResolveItem(item)

    local itemid = item:GetEntityIndex()
    local itemname = item:GetAbilityName()

    -- TODO TEMP
    local i = 11 -- Add weapon to slot 11.

    self.items[itemid] = i
    self.itemNames[itemname] = self.itemNames[itemname] or {}
    self.itemNames[itemname][itemid] = i

    -- Dunno if necessary
    item:SetOwner(self.hero)
    -- ApplyPassives(self, item)

    -- Notify client
    PlayerTables:SetTableValue(self.tableName, 'slot'..i, itemid)

    -- Testing
    ApplyPassives(self.hero, item)

    return true
end

function Inventory:GetItemInSlot(slotId)
    if type(slotId) == 'number' then
        slotId = 'slot'..slotId
    end
    -- Shouldn't we just pull it from a local table...?
    local item = PlayerTables:GetTableValue(self.tableName, slotId)
    if item then
        item = ResolveItem(item)
        if item and not IsValidEntity(item) then
            print('Item became invalid...?')
            PlayerTables:DeleteTableKey(self.tableName, slotId)
            return nil
        end
        if item and IsValidEntity(item) and item.IsItem and item:IsItem() then
            return item
        end
        print('Found something, but not invalid, but not item...?')
    end
    return nil
end

function Inventory:IsItemInSlot(i)
    return self:GetItemInSlot(i) ~= nil
end
