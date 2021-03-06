---
--@type Filters
Filters = Filters or class({})

FILTER_EXECUTION_CANCEL = false
FILTER_EXECUTION_CONTINUE = true

---
--@function [parent=#Filters] Activate
--@param self
function Filters:Activate()
    self:ActivateOrderFilter()
    self:ActivateModifyExperienceFilter()
    self:ActivateModifierGainedFilter()
    Debug('Filters', 'Activated')
end

---
--@function [parent=#Filters] ActivateOrderFilter
--@param self
function Filters:ActivateOrderFilter()
    local mode = GameRules:GetGameModeEntity()
    mode:SetExecuteOrderFilter(Dynamic_Wrap(Filters, 'OrderFilter'), Filters)
    mode.SetExecuteOrderFilter = function(mode, callback, context)
        Debug('Filters', '[NOTICE] SetExecuteOrderFilter should not be called directly')
        Event:Listen('FilterOrderFilter', callback, context)
    end
end

---
--@function [parent=#Filters] ActivateModifyExperienceFilter
--@param self
function Filters:ActivateModifyExperienceFilter()
    local mode = GameRules:GetGameModeEntity()
    mode:SetModifyExperienceFilter(Dynamic_Wrap(Filters, 'ModifyExperienceFilter'), Filters)
    mode.SetModifyExperienceFilter = function(mode, callback, context)
        Debug('Filters', '[NOTICE] SetModifyExperienceFilter should not be called directly')
        Event:Listen('FilterModifyExperienceFilter', callback, context)
    end
end

function Filters:ActivateModifierGainedFilter()
    local mode = GameRules:GetGameModeEntity()
    mode:SetModifierGainedFilter(Dynamic_Wrap(Filters, 'ModifierGainedFilter'), Filters)
    mode.SetModifierGainedFilter = function(mode, callback, context)
        Debug('Filters', '[NOTICE] SetModifierGainedFilter should not be called directly')
        Event:Listen('FilterModifierGainedFilter', callback, context)
    end
end

---
--@function [parent=#Filters] OrderFilter
--@param self
--@param #table order
function Filters:OrderFilter(order)
    Debug('Filters', 'OrderFilter Fired')
--    Debug('Filters', '-------------------------------------------------------')
--    Debug('Filters', 'Type:', order.order_type, ORDERS[order.order_type])
--    Debug('Filters', 'Queue:', order.queue)

    return Event:Trigger('FilterOrderFilter', order)
end

---
--@function [parent=#Filters] ModifyExperienceFilter
--@param self
--@param #table params
function Filters:ModifyExperienceFilter(params)
    Debug('Filters', 'ModifyExperienceFilter Fired')
    return Event:Trigger('FilterModifyExperienceFilter', params)
end

function Filters:ModifierGainedFilter(params)
    Debug('Filters', 'ModifierGainedFilter Fired')
    -- DeepPrintTable(params)
    local result = Event:Trigger('FilterModifierGainedFilter', params)
    -- If no callback returned false explicitly, then we want to return true.
    if result == nil then result = true end
    return result
end

---
-- Convenience Wrapper
--
--@function [parent=#Filters] OnOrderFilter
--@param self
--@param #function callback
--@param #table context
function Filters:OnOrderFilter(callback, context)
    Debug('Filters', 'OnOrderFilter Callback Listening')
    self:Listen('OrderFilter', callback, context)
end

---
-- Convenience Wrapper
--
--@function [parent=#Filters] OnModifyExperienceFilter
--@param self
--@param #function callback
--@param #table context
function Filters:OnModifyExperienceFilter(callback, context)
    Debug('Filters', 'OnModifyExperienceFilter Callback Listening')
    self:Listen('ModifyExperienceFilter', callback, context)
end

function Filters:OnModifierGainedFilter(callback, context)
    Debug('Filters', 'OnModifierGainedFilter Callback Listening')
    self:Listen('ModifierGainedFilter', callback, context)
end

---
--@function [parent=#Filters] Listen
--@param self
--@param #string filterName
--@param #function callback
--@param #table context
function Filters:Listen(filterName, callback, context)
    Event:Listen('Filter'..filterName, callback, context)
end


if not Filters.initialized then
    Filters.initialized = true
    Event:Listen('Activate', Dynamic_Wrap(Filters, 'Activate'), Filters)
end


-- Order Filter Types
ORDERS = {
    [0] = "DOTA_UNIT_ORDER_NONE",
    [1] = "DOTA_UNIT_ORDER_MOVE_TO_POSITION",
    [2] = "DOTA_UNIT_ORDER_MOVE_TO_TARGET",
    [3] = "DOTA_UNIT_ORDER_ATTACK_MOVE",
    [4] = "DOTA_UNIT_ORDER_ATTACK_TARGET",
    [5] = "DOTA_UNIT_ORDER_CAST_POSITION",
    [6] = "DOTA_UNIT_ORDER_CAST_TARGET",
    [7] = "DOTA_UNIT_ORDER_CAST_TARGET_TREE",
    [8] = "DOTA_UNIT_ORDER_CAST_NO_TARGET",
    [9] = "DOTA_UNIT_ORDER_CAST_TOGGLE",
    [10] = "DOTA_UNIT_ORDER_HOLD_POSITION",
    [11] = "DOTA_UNIT_ORDER_TRAIN_ABILITY",
    [12] = "DOTA_UNIT_ORDER_DROP_ITEM",
    [13] = "DOTA_UNIT_ORDER_GIVE_ITEM",
    [14] = "DOTA_UNIT_ORDER_PICKUP_ITEM",
    [15] = "DOTA_UNIT_ORDER_PICKUP_RUNE",
    [16] = "DOTA_UNIT_ORDER_PURCHASE_ITEM",
    [17] = "DOTA_UNIT_ORDER_SELL_ITEM",
    [18] = "DOTA_UNIT_ORDER_DISASSEMBLE_ITEM",
    [19] = "DOTA_UNIT_ORDER_MOVE_ITEM",
    [20] = "DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO",
    [21] = "DOTA_UNIT_ORDER_STOP",
    [22] = "DOTA_UNIT_ORDER_TAUNT",
    [23] = "DOTA_UNIT_ORDER_BUYBACK",
    [24] = "DOTA_UNIT_ORDER_GLYPH",
    [25] = "DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH",
    [26] = "DOTA_UNIT_ORDER_CAST_RUNE",
    [27] = "DOTA_UNIT_ORDER_PING_ABILITY",
    [28] = "DOTA_UNIT_ORDER_MOVE_TO_DIRECTION",
    [29] = "DOTA_UNIT_ORDER_PATROL",
    [30] = "DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION",
    [31] = "DOTA_UNIT_ORDER_RADAR",
    [32] = "DOTA_UNIT_ORDER_SET_ITEM_COMBINE_LOCK",
    [33] = "DOTA_UNIT_ORDER_CONTINUE",
}
