
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
InventoryService = InventoryService or class({})

function InventoryService:Activate()
    self:LoadItemData()

    Filters:OnOrderFilter(Dynamic_Wrap(InventoryService, 'OrderFilter'), InventoryService)

    CustomGameEventManager:RegisterListener("InventoryService_OnLeftClick", Dynamic_Wrap(InventoryService, "InventoryService_OnLeftClick"))
    CustomGameEventManager:RegisterListener("InventoryService_OnRightClick", Dynamic_Wrap(InventoryService, "InventoryService_OnRightClick"))
    CustomGameEventManager:RegisterListener("InventoryService_OnDragFrom", Dynamic_Wrap(InventoryService, "InventoryService_OnDragFrom"))

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

    self.itemPassives = {}
    for id,itemName in pairs(self.itemIDs) do
        local kv = self.itemKV[itemName]
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
    DeepPrintTable(self.itemPassives)
end

function InventoryService:InventoryService_OnLeftClick(event)
    Debug('InventoryService', 'InventoryService_OnLeftClick')
end
function InventoryService:InventoryService_OnRightClick(event)
    Debug('InventoryService', 'InventoryService_OnRightClick')
end
function InventoryService:InventoryService_OnDragFrom(event)
    Debug('InventoryService', 'InventoryService_OnDragFrom')
end
function InventoryService:OrderFilter(event, order)
    -- TODO: Range cancel/abort?
    if order.units["0"] and order.order_type == DOTA_UNIT_ORDER_PICKUP_ITEM then
        InventoryService:OrderFilterPickupItem(event, order)
    end
end

function InventoryService:AddItem(hero, item)
    print('Adding '..item:GetName()..' to '..hero:GetName())
end

function InventoryService:OrderFilterPickupItem(event, order)
    -- For now, ranged pickup lol!
    local hero = EntIndexToHScript(order.units["0"])
    local physItem = EntIndexToHScript(order.entindex_target)
    if not physItem then return false end
    local item = physItem:GetContainedItem()
    if item and InventoryService:AddItem(hero, item) then
        physItem:RemoveSelf()
    end

    -- TODO
    if true then return false end

    local unit = EntIndexToHScript(order.units["0"])
    local physItem = EntIndexToHScript(order.entindex_target)
    local unitpos = unit:GetAbsOrigin()
    if not physItem then return false end
    local diff = unitpos - physItem:GetAbsOrigin()
    local dist = diff:Length2D()
    local pos = unitpos
    if dist > 90 then
        pos = physItem:GetAbsOrigin() + diff:Normalized() * 90
    end
    local defInventoryService = Containers:GetDefaultInventoryService(unit)
    if defInventoryService then
        order.order_type = DOTA_UNIT_ORDER_MOVE_TO_POSITION
        order.position_x = pos.x
        order.position_y = pos.y
        order.position_z = pos.z

        Containers.rangeActions[order.units["0"]] = {
            unit = unit,
            position = physItem:GetAbsOrigin(),
            range = 100,
            playerID = issuerID,
            action = function(playerID, container, unit, target)
                if IsValidEntity(physItem) then
                    local item = physItem:GetContainedItem()
                    if item and defInventoryService:AddItem(item) then
                        physItem:RemoveSelf()
                    end
                end
            end,
        }
    end

end

-- Event:BindActivate(InventoryService)

-- InventoryService:Activate()
