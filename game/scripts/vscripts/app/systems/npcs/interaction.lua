---
-- @type Interaction
Interaction = Interaction or class({}, {
    rangedActions = {}
})

function Interaction:Activate()
    Timers:CreateTimer(function()
        for id, action in pairs(Interaction.rangedActions) do
            -- Pythagorean
            local rangeSquared = 150 * 150
            local distance = action.unit:GetAbsOrigin() - action.targetPosition
            local rangeCurrent = distance.x * distance.x + distance.y + distance.y
            if not action.inverseCheck then
                -- Check if position is inside the range.
                if rangeCurrent <= rangeSquared then
                    action.callback(action)
                    Interaction.rangedActions[id] = nil
                end
            else
                -- Check if position is beyond the range.
                if rangeCurrent > rangeSquared then
                    action.callback(action)
                    Interaction.rangedActions[id] = nil
                end
            end
        end
        return 0.03
    end)
    Filters:OnOrderFilter(Dynamic_Wrap(Interaction, 'OrderFilter'), Interaction)
    Debug('Interaction', 'Activated')
end

---
--@function [parent=#Interaction] RangedAction
--@param self
function Interaction:RangedAction(action)
--[[ action = {
          unit
          target
          targetPosition
          inverseCheck = true if checking for moving OUT of the range.
    } ]]
end

function Interaction:StartInteraction(action)
    QuestService:OnRightClickQuestGiver(action)
end

function Interaction:OrderFilter(event, order)
    
    -- TODO: Test Queue
    
    -- Clear out any current rangedActions by this character.
    -- TODO: Consider move-out-of-range watchers like quest dialogs.
    if order.units['0'] then
        Interaction.rangedActions[order.units['0']] = nil
    end
    
    -- The main order we're watching for.
    if order.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET then
        Debug('Interaction', 'DOTA_UNIT_ORDER_MOVE_TO_TARGET')
        local target = EntIndexToHScript(order.entindex_target)
        
        -- TODO: IsNPC?
        if target.quest then
            local action = {
                PlayerID = order.issuer_player_id_const,
                unit = EntIndexToHScript(order.units['0']),
                target = target,
                targetPosition = target:GetAbsOrigin(),
                callback = function(action)
                    Debug('Interaction', 'Arrived at move target.')
                    action.unit:Stop()
                    Interaction:StartInteraction(action)
                end
            }
            Interaction.rangedActions[order.units['0']] = action
        end
        
        return FILTER_EXECUTION_CONTINUE
    end
    
    return FILTER_EXECUTION_CONTINUE
end

if not Interaction.initialized then
    Interaction.initialized = true
    Event:Listen('Activate', Dynamic_Wrap(Interaction, 'Activate'), Interaction)
end
