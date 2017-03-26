---
-- @type FocusTarget
FocusTarget = FocusTarget or class({})

function FocusTarget:Activate()
    Filters:OnOrderFilter(Dynamic_Wrap(FocusTarget, 'OrderFilter'), FocusTarget)
    CustomGameEventManager:RegisterListener('focus_target', Dynamic_Wrap(FocusTarget, 'OnFocusTarget'))
end

function FocusTarget:OnFocusTarget(event)
    Debug('FocusTarget', 'Set '..event.PlayerID..' to '..event.target)
    Wrappers.SetNetTable('focus_target', event.PlayerID, event.target)
end

function FocusTarget:OrderFilter(event, order)
    -- We only care if the spell has no target.
    if order.order_type == DOTA_UNIT_ORDER_CAST_NO_TARGET then
        -- Grab the ability
        local ability = EntIndexToHScript(order.entindex_ability)
        
        -- Make sure it is a custom target ability and not just a normal no-cast ability.
        if ability.UseCustomTarget and ability:UseCustomTarget() then
            local caster = ability:GetCaster()
            local target = Wrappers.GetFocusTarget(caster)
            if target then
                ability.customTargetCasting = true
                ExecuteOrderFromTable({
                    OrderType    = DOTA_UNIT_ORDER_CAST_TARGET,
                    UnitIndex    = caster:entindex(),
                    TargetIndex  = target:entindex(),
                    AbilityIndex = order.entindex_ability,
                    Queue        = false
                })
                ability.customTargetCasting = false
            end
            
            return FILTER_EXECUTION_CANCEL
        end
    end
    
    return FILTER_EXECUTION_CONTINUE
end

Event:BindActivate(FocusTarget)
