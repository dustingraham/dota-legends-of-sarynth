
local ResolveItem = function(item)
    if type(item) == 'number' then
        return EntIndexToHScript(item)
    end
    if item and IsValidEntity(item) and item.IsItem and item:IsItem() then
        return item
    end
    return nil
end

local IsInRange = function(value, min, max)
    return value >= min and value <= max
end
local IsEquipmentSlot = function(iSlotId)
    return IsInRange(iSlotId, 1, 12)
end
local IsBackpackSlot = function(iSlotId)
    return IsInRange(iSlotId, 13, 48)
end
local IsInventorySlot = function(iSlotId)
    return IsBackpackSlot(iSlotId) or IsEquipmentSlot(iSlotId)
end
local IsShopSlot = function(iSlotId)
    return IsInRange(iSlotId, 101, 136)
end
local IsBuybackSlot = function(iSlotId)
    return IsInRange(iSlotId, 151, 156)
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
    PlayerTables:CreateOrSubscribe(self.tableName, {}, {hero:GetPlayerOwnerID()})
    Debug('Inventory', 'Created PlayerTable: ', self.tableName)
end

function Inventory:FindOpenBackpackSlot()
    for i = 13, 48 do
        if not self:IsItemInSlot(i) then
            return i
        end
    end

    return nil
end

-- Used during character load
function Inventory:CreateItem(itemName, slotId)
    local item = CreateItem(itemName, self.hero, self.hero)
    -- Prevent recording the acquire event during load.
    item.initialCreate = true
    self:PickupItem(item, slotId)
end

-- Consider getting a unique token from server for legendary items.
function Inventory:PickupItem(item, slotId)
    item = ResolveItem(item)
    local itemid = item:GetEntityIndex()
    local itemname = item:GetAbilityName()

    if slotId ~= nil then
        slotId = tonumber(string.match(slotId, "%d+"))
        if slotId > 12 or self:CheckCompatibleSlot(slotId, item) then
            self.items[itemid] = slotId
            self.itemNames[itemname] = self.itemNames[itemname] or {}
            self.itemNames[itemname][itemid] = slotId

            if slotId <= 12 then
                ApplyPassives(self.hero, item)
            end

            -- Notify client
            PlayerTables:SetTableValue(self.tableName, 'slot'..slotId, itemid)
            Event:Trigger('InventoryAdd', {
                hero = self.hero,
                item = item
            })
            return true
        else
            Debug('Inventory', 'Invalid slot placement. Dropping in backpack.')
            slotId = nil
        end
    end

    -- Straight add item will go to backpack.
    -- Find a place and place it
    local i = self:FindOpenBackpackSlot()

    -- No Room
    if not i then return false end

    -- Place the item!
    self.items[itemid] = i
    self.itemNames[itemname] = self.itemNames[itemname] or {}
    self.itemNames[itemname][itemid] = i

    -- Dunno if necessary
    item:SetOwner(self.hero)
    -- ApplyPassives(self, item)

    -- Notify client
    PlayerTables:SetTableValue(self.tableName, 'slot'..i, itemid)
    Event:Trigger('InventoryAdd', {
        hero = self.hero,
        item = item
    })
    return true
end

function Inventory:GetItemCount(itemName)
    local count = 0
    for i = 1, 48 do
        local item = self:GetItemInSlot(i)
        if item ~= nil then
            --print(item:GetAbilityName())
            if item:GetAbilityName() == itemName then
                -- Check item matches name, then check stack counts...
                -- TODO: Inventory Stacking
                count = count + 1
            end
        end
    end
    return count
end

function Inventory:RightClickShopping(fromSlotId, toSlotId)
    if toSlotId then
        error('Expected toSlotId to be nil')
    end

    -- Check if we're trying to buy-back an item.
    local fromSlotNumericId = tonumber(string.match(fromSlotId, "%d+"))
    if IsBuybackSlot(fromSlotNumericId) then
        self:BuybackSlot(fromSlotNumericId)
        return
    end
    if IsInventorySlot(fromSlotNumericId) then
        self:SellSlot(fromSlotNumericId)
        return
    end
    if IsShopSlot(fromSlotNumericId) then
        self:BuySlot(fromSlotNumericId)
        return
    end

    error('Unexpected right click slot.')
end

function Inventory:BuySlot(slotId)
    Debug('Inventory', 'Buy not supported yet.')
end

function Inventory:BuybackSlot(fromSlotId, toSlotId)
    -- Check that "to" slot is not populated. If it is, abort.
    -- Find an open slot if toSlotId is nil

    if toSlotId then
        local toItem = self:GetItemInSlot(toSlotId)
        if toItem then
            Debug('Inventory', 'Slot is occupied, aborting.')
            Sounds:EmitSoundOnClient(self.hero:GetPlayerOwnerID(), 'General.Cancel')
            return
        end
    else
        toSlotId = self:FindOpenBackpackSlot()
        if not toSlotId then
            Debug('Inventory', 'Buyback failed, no room in backpack.')
            Sounds:EmitSoundOnClient(self.hero:GetPlayerOwnerID(), 'General.Cancel')
            return
        end
        toSlotId = 'slot'..toSlotId
    end

    local fromItem = self:GetItemInSlot(fromSlotId)
    local price = fromItem:GetCost()
    if self.hero:GetGold() < price then
        Debug('Inventory', 'Buyback failed, not rich enough.', price)
        Sounds:EmitSoundOnClient(self.hero:GetPlayerOwnerID(), 'General.Cancel')
        return
    end

    self.hero:SpendGold(price, DOTA_ModifyGold_PurchaseItem)
    Sounds:EmitSoundOnClient(self.hero:GetPlayerOwnerID(), 'General.Buy')

    -- Buying the item into the slot.
    local toItemSlotId = tonumber(string.match(toSlotId, "%d+"))
    local fromItemSlotId = tonumber(string.match(fromSlotId, "%d+"))
    local fromItemId = fromItem:GetEntityIndex()
    local fromItemName = fromItem:GetAbilityName()
    self.items[fromItemId] = toItemSlotId
    self.itemNames[fromItemName][fromItemId] = toItemSlotId
    PlayerTables:SetTableValue(self.tableName, "slot"..toItemSlotId, fromItemId)
    PlayerTables:DeleteTableKey(self.tableName, "slot"..fromItemSlotId)
end

-- We are doing some assumptions on the client being honest.
-- Need to ensure we're doing the right thing.
function Inventory:SellSlot(fromSlotId, toSlotId)
    -- Check if we're trying to buy-back an item.
    local fromSlotNumericId = tonumber(string.match(fromSlotId, "%d+"))
    if not IsInventorySlot(fromSlotNumericId) then
        error('Unexpected sell from slot.')
        return
    end

    if not toSlotId then
        -- For now the target slot id is simply 151.
        toSlotId = 'slot151'
        -- Need to move slots down by one...
        if not self:ShiftBuyback(toSlotId) then
            Debug('Inventory', 'Cancelling sell, failed to shift.')
            return
        end
    end
    -- Debug('Inventory', 'Destination: ', toSlotId)

    local fromItem = self:GetItemInSlot(fromSlotId)

    -- Accounting: Only pay 90% of item's value. (Update dialog window if that changes.)
    local price = fromItem:GetCost() * 0.90
    --Debug('Inventory', 'Selling for: ', price)
    self.hero:ModifyGold(price, true, DOTA_ModifyGold_SellItem)
    local player = self.hero:GetPlayerOwner()
    -- Overhead Message for Gold auto plays sound and popup.
    SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, self.hero, price, player)
    -- PopupGoldGain(self.hero, price)
    --Sounds:EmitSoundOnClient(self.hero:GetPlayerOwnerID(), 'General.Sell')

    -- Selling the item into the slot.
    local toItemSlotId = tonumber(string.match(toSlotId, "%d+"))
    local fromItemSlotId = tonumber(string.match(fromSlotId, "%d+"))
    local fromItemId = fromItem:GetEntityIndex()
    local fromItemName = fromItem:GetAbilityName()

    self.items[fromItemId] = toItemSlotId
    self.itemNames[fromItemName][fromItemId] = toItemSlotId
    PlayerTables:SetTableValue(self.tableName, "slot"..toItemSlotId, fromItemId)
    PlayerTables:DeleteTableKey(self.tableName, "slot"..fromItemSlotId)
end

function Inventory:ShiftInventory()
    return self:ShiftSlots(slotId, 13, 48, true)
end

function Inventory:ShiftBuyback(slotId)
    return self:ShiftSlots(slotId, 151, 156, false)
end

function Inventory:ShiftSlots(slotId, minShift, maxShift, errorIfFull)
    local item = self:GetItemInSlot(slotId)
    if not item then
        Debug('InventoryDebug', 'Target slot is empty, no need to shift.', slotId)
        return true
    end

    local iSlotId = tonumber(string.match(slotId, "%d+"))
    if iSlotId < minShift or iSlotId > maxShift then
        Debug('Inventory', 'Invalid shift?', minShift, iSlotId, maxShift)
        error('Invalid shift: ', minShift, iSlotId, maxShift)
        return false
    end

    -- Check current slot range.
    if iSlotId >= maxShift then
        if errorIfFull then
            Debug('Inventory', 'Erroring, slots are full!')
            return false
        else
            Debug('InventoryDebug', 'Last slot will be overwritten.')
            -- TODO: RemoveSelf on item?
            -- We were successful, returning true.
            return true
        end
    end

    -- Check next slot.
    local nextSlotId = iSlotId + 1
    local nextItem = self:GetItemInSlot(nextSlotId)

    -- Recursive... if next slot is not empty, try to bump it. Then bump this one.
    if nextItem then
        self:ShiftSlots(nextSlotId, minShift, maxShift, errorIfFull)
    else
        Debug('InventoryDebug', 'Next slot is empty')
    end

    -- Swap current item into next slot, since it is empty.
    Debug('InventoryDebug', 'Moving this one down', nextSlotId)
    self:SwapSlots(slotId, nextSlotId)

    -- Success
    return true
end

function Inventory:SwapSlotRequest(fromSlotId, toSlotId)
    -- Determine if this is a sale attempt.
    local toItemSlotId = tonumber(string.match(toSlotId, "%d+"))
    local fromItemSlotId = tonumber(string.match(fromSlotId, "%d+"))
    if IsBuybackSlot(toItemSlotId) and IsBuybackSlot(fromItemSlotId) then
        Debug('Inventory', 'Swapping buyback history slots.')
        Sounds:EmitSoundOnClient(self.hero:GetPlayerOwnerID(), 'Item.DropShop')
        self:SwapSlots(fromSlotId, toSlotId)
        return
    end

    -- Player swapping own inventory.
    if IsInventorySlot(fromItemSlotId) and IsInventorySlot(toItemSlotId) then
        Debug('Inventory', 'Player own inventory swap.')
        Sounds:EmitSoundOnClient(self.hero:GetPlayerOwnerID(), 'Item.DropShop')
        self:SwapSlots(fromSlotId, toSlotId)
        return
    end

    -- Player dropping in shop. SELL IT.
    if IsInventorySlot(fromItemSlotId) and IsShopSlot(toItemSlotId) then
        Debug('Inventory', 'Player item dropped on shop. Selling.')
        -- Since they dropped it on the shop, we do not want to place the item in the shop.
        -- So we omit toSlotId in order to shift items in the buyback list.
        self:SellSlot(fromSlotId, nil)
        return
    end

    -- Player dropping in buyback. SELL IT.
    if IsInventorySlot(fromItemSlotId) and IsBuybackSlot(toItemSlotId) then
        Debug('Inventory', 'Player item dropped on buyback. Selling.')
        self:SellSlot(fromSlotId, toSlotId)
        return
    end

    -- Player dragging from shop to own inventory. BUY IT.
    if IsShopSlot(fromItemSlotId) and IsInventorySlot(toItemSlotId) then
        Debug('Inventory', 'Player wants to buy item. (Not yet.)')
        return
    end

    -- Player dragging from buyback to own inventory. BUY BACK.
    if IsBuybackSlot(fromItemSlotId) and IsInventorySlot(toItemSlotId) then
        Debug('Inventory', 'Player wants to buyback item.')
        self:BuybackSlot(fromSlotId, toSlotId)
        return
    end

    -- Deny BB->Shop, Shop->BB, Shop->Shop
    if IsBuybackSlot(fromItemSlotId) and IsShopSlot(toItemSlotId) or
       IsShopSlot(fromItemSlotId) and IsBuybackSlot(toItemSlotId) or
       IsShopSlot(fromItemSlotId) and IsShopSlot(toItemSlotId) then
        Debug('Inventory', 'Invalid drag request.')
        Sounds:EmitSoundOnClient(self.hero:GetPlayerOwnerID(), 'General.Cancel')
        return
    end

    error('Unrecognized drag and drop exchange.')
end

function Inventory:SwapSlots(fromSlotId, toSlotId)
    local fromItem = self:GetItemInSlot(fromSlotId)
    if not fromItem then
        -- Do we need or want to determine whether toItem is nil at this point?
        error('Invalid slot swap.')
    end

    local toItem = self:GetItemInSlot(toSlotId)
    if toItem then
        self:SwapItems(fromItem, toItem)
        return
    end

    -- Moving fromItem to empty slot.
    local toItemSlotId = tonumber(string.match(toSlotId, "%d+"))
    local fromItemSlotId = tonumber(string.match(fromSlotId, "%d+"))
    local fromItemId = fromItem:GetEntityIndex()
    local fromItemName = fromItem:GetAbilityName()
    self.items[fromItemId] = toItemSlotId
    self.itemNames[fromItemName][fromItemId] = toItemSlotId
    PlayerTables:SetTableValue(self.tableName, "slot"..toItemSlotId, fromItemId)
    PlayerTables:DeleteTableKey(self.tableName, "slot"..fromItemSlotId)
    if fromItemSlotId <= 12 then
        RemovePassives(self.hero, fromItem)
    end
    if toItemSlotId <= 12 then
        ApplyPassives(self.hero, fromItem)
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

function Inventory:GetAllItems()
    return PlayerTables:GetAllTableValues(self.tableName)
end

function Inventory:DropToWorld(fromSlotId, position)
    if not self:IsItemInSlot(fromSlotId) then return end

    local fromItem = self:GetItemInSlot(fromSlotId)
    if not fromItem:IsDroppable() then
        print('TODO: Send message to user, you can not drop that...')
        return
    end

    -- Remap position...
    if not position["0"] or not position["1"] or not position["2"] then return end
    position = Vector(position["0"], position["1"], position["2"])

    local fromItemSlotId = tonumber(string.match(fromSlotId, "%d+"))
    local fromItemId = fromItem:GetEntityIndex()
    local fromItemName = fromItem:GetAbilityName()

    self.items[fromItemId] = nil
    self.itemNames[fromItemName][fromItemId] = nil
    PlayerTables:DeleteTableKey(self.tableName, "slot"..fromItemSlotId)
    if fromItemSlotId <= 12 then
        RemovePassives(self.hero, fromItem)
    end

    -- Place it in the world
    CreateItemOnPositionSync(position, fromItem)
    Event:Trigger('InventoryRemove', {
        hero = self.hero,
        item = fromItem
    })
end

-- Currently special for quest removal. Generalize...?
-- There may be 3-5 of the same item. Purge all.
function Inventory:RemoveItemsByName(itemName)
    for i = 1, 48 do
        local item = self:GetItemInSlot(i)
        if item ~= nil then
            --print(item:GetAbilityName())
            if item:GetAbilityName() == itemName then
                self:RemoveItemInSlot(i)
            end
        end
    end
end

function Inventory:RemoveItemInSlot(slotId)
    local item = self:GetItemInSlot(slotId)
    if not item:IsQuestItem() then
        print('Error: Currently only expect quest items...')
        return
    end

    local fromItemSlotId = tonumber(string.match(slotId, "%d+"))
    local fromItemId = item:GetEntityIndex()
    local fromItemName = item:GetAbilityName()

    self.items[fromItemId] = nil
    self.itemNames[fromItemName][fromItemId] = nil
    PlayerTables:DeleteTableKey(self.tableName, "slot"..fromItemSlotId)
    if fromItemSlotId <= 12 then
        print('Error: Not expecting equipped items...')
        RemovePassives(self.hero, item)
    end

    Event:Trigger('InventoryRemove', {
        hero = self.hero,
        item = item
    })
end
