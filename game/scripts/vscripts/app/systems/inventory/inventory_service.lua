
local applied = {}

local ApplyPassives = function(hero, item)
    -- Check if it is already applied
    if applied[item:GetEntityIndex()] then return end
    -- We may need to loop through buffs anyways to check.

    applied[item:GetEntityIndex()] = {}
    for _,passive in ipairs(passives) do
        item:ApplyDataDrivenModifier(ent, ent, passive, {})
        buffs = ent:FindAllModifiersByName(passive)
        for _, buff in ipairs(buffs) do
            if buff:GetAbility() == item then
                table.insert(container.appliedPassives[item:GetEntityIndex()], buff)
                break
            end
        end
    end
    passives = item:GetIntrinsicModifierName()
    if passives then
        local buff = ent:AddNewModifier(ent, item, passives, {})
        container.appliedPassives[item:GetEntityIndex()] = {buff}
    end
end


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
--@type InventoryService
InventoryService = InventoryService or class({}, {
    rangedActions = {}
})

function InventoryService:Activate()
    self:LoadItemData()

    Filters:OnOrderFilter(Dynamic_Wrap(InventoryService, 'OrderFilter'), InventoryService)

    --CustomGameEventManager:RegisterListener("InventoryService_OnLeftClick", Dynamic_Wrap(InventoryService, "InventoryService_OnLeftClick"))
    --CustomGameEventManager:RegisterListener("InventoryService_OnRightClick", Dynamic_Wrap(InventoryService, "InventoryService_OnRightClick"))

    CustomGameEventManager:RegisterListener("Inventory_OnDragDrop", Dynamic_Wrap(InventoryService, 'OnDragDrop'))
    CustomGameEventManager:RegisterListener("Inventory_OnDragWorld", Dynamic_Wrap(InventoryService, 'OnDragWorld'))

    -- TODO: Remove duplicate...
    Timers:CreateTimer(function()
        for id, action in pairs(InventoryService.rangedActions) do
            -- Pythagorean
            local rangeSquared = 150 * 150
            local distance = action.unit:GetAbsOrigin() - action.targetPosition
            local rangeCurrent = distance.x * distance.x + distance.y * distance.y
            -- Check if position is inside the range.
            if rangeCurrent <= rangeSquared then
                local status, result = xpcall(
                    function() return action.callback(action) end,
                    function (msg) return msg..'\n'..debug.traceback()..'\n' end
                )
                InventoryService.rangedActions[id] = nil
                if not status then Debug('InventoryService', '[ERROR]', result) end
            end
        end
        return 0.03
    end)

    Debug('InventoryService', 'Activated')
end

function InventoryService:LoadItemData()
    self.itemKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")
    self.itemIDs = {}
    for k,v in pairs(self.itemKV) do
        if type(v) == "table" and v.ID then
            self.itemIDs[v.ID] = k
        end
    end
    self.itemQualities = {}
    self.itemPassives = {}
    for id,itemName in pairs(self.itemIDs) do
        local kv = self.itemKV[itemName]
        self.itemQualities[itemName] = kv.ItemQuality
        if kv.BaseClass == "item_datadriven" then
            self.itemPassives[itemName] = {}
            if kv.Modifiers then
                for modname, mod in pairs(kv.Modifiers) do
                    if mod.Passive == 1 then
                        table.insert(self.itemPassives[itemName], modname)
                    end
                end
            end
        end
    end
    --DeepPrintTable(self.itemQualities)
    --DeepPrintTable(self.itemPassives)
end

function InventoryService:GetItemQuality(itemName)
    return self.itemQualities[itemName]
end

function InventoryService:InventoryService_OnLeftClick(event)
    Debug('InventoryService', 'InventoryService_OnLeftClick')
end
function InventoryService:InventoryService_OnRightClick(event)
    Debug('InventoryService', 'InventoryService_OnRightClick')
end

function InventoryService:OnDragWorld(event)
    Debug('InventoryService', 'OnDragWorld')
    -- DeepPrintTable(event)
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    local position = Vector(event.position["0"], event.position["1"], event.position["2"])

    local unitpos = hero:GetAbsOrigin()
    local diff = unitpos - position
    local dist = diff:Length2D()
    local pos = unitpos
    if dist > 150 *.9 then
        pos = position + diff:Normalized() * 150 * .9
    end

    ExecuteOrderFromTable({
                              UnitIndex = hero:GetEntityIndex(),
                              OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                              Position =  pos,
                          })
    InventoryService.rangedActions[hero:GetEntityIndex()] = {
        unit = hero,
        targetPosition = pos,
        range = 150,
        playerID = event.PlayerID,
        callback = function(action)
            print('Callback happening...')
            hero.inventory:DropToWorld(event.slotFrom, event.position)
        end,
    }
end

function InventoryService:OnDragDrop(event)
    Debug('InventoryService', 'OnDragDrop')
    -- DeepPrintTable(event)
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    hero.inventory:SwapSlots(event.slotFrom, event.slotTo)
end

function InventoryService:OrderFilter(event, order)
    -- TODO: Range cancel/abort?
    if order.units["0"] and order.order_type == DOTA_UNIT_ORDER_PICKUP_ITEM then
        InventoryService:OrderFilterPickupItem(event, order)
        return true
    end
end

function InventoryService:AddItem(hero, item)
    --print('Adding '..item:GetName()..' to '..hero:GetName())
    hero.inventory:AddItem(item)
    return true
end

function InventoryService:OrderFilterPickupItem(event, order)
    --print('Order Filter Fire')
    --DeepPrintTable(event)
    --DeepPrintTable(order)
    --print('=---=')

    -- For now, ranged pickup lol!
    --local hero = EntIndexToHScript(order.units["0"])
    --local physItem = EntIndexToHScript(order.entindex_target)
    --if not physItem then return false end
    --local item = physItem:GetContainedItem()
    --if item and InventoryService:AddItem(hero, item) then
    --    physItem:RemoveSelf()
    --end

    if order.units['0'] then
        InventoryService.rangedActions[order.units["0"]] = nil
    end

    local hero = EntIndexToHScript(order.units["0"])
    local physItem = EntIndexToHScript(order.entindex_target)
    if not physItem then return false end
    local unitpos = hero:GetAbsOrigin()
    local diff = unitpos - physItem:GetAbsOrigin()
    local dist = diff:Length2D()
    local pos = unitpos
    if dist > 90 then
        pos = physItem:GetAbsOrigin() + diff:Normalized() * 90
    end

    -- Convert to move order.
    order.order_type = DOTA_UNIT_ORDER_MOVE_TO_POSITION
    order.position_x = pos.x
    order.position_y = pos.y
    order.position_z = pos.z

    InventoryService.rangedActions[order.units["0"]] = {
        unit = hero,
        targetPosition = physItem:GetAbsOrigin(),
        range = 150,
        playerID = order.issuer_player_id_const,
        callback = function(action)
            if IsValidEntity(physItem) then
                local item = physItem:GetContainedItem()
                if item and InventoryService:AddItem(hero, item) then
                    physItem:RemoveSelf()
                end
            end
        end,
    }
end

Event:BindActivate(InventoryService)

-- InventoryService:Activate()
