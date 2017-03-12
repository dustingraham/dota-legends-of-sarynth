---
-- @type FocusTarget
FocusTarget = FocusTarget or class({})

function FocusTarget:Activate()
    Filters:OnOrderFilter(Dynamic_Wrap(FocusTarget, 'OrderFilter'), FocusTarget)
    CustomGameEventManager:RegisterListener('focus_target', Dynamic_Wrap(FocusTarget, 'OnFocusTarget'))
end

function FocusTarget:OnFocusTarget(event)
    Debug('FocusTarget', 'Set '..event.PlayerID..' to '..event.target)
--    
--    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
--    if hero then
--        hero.focusTarget = event.target
--    else
--        Debug('FocusTarget', 'Hero not available yet...')
--    end
--    
    Wrappers.SetNetTable('focus_target', event.PlayerID, event.target)
end

function BindActivate(target)
    if not target.initialized then
        target.initialized = true
        Event:Listen('Activate', Dynamic_Wrap(target, 'Activate'), target)
    end
end

BindActivate(FocusTarget)

--function GetUnitTarget(entity)
--    if not IsValidEntity(entity.focusTarget) then return nil end
--    return EntIndexToHScript(entity.focusTarget)
--end


--function GetHeroID( player )
--    player = type( player ) == 'number' and PlayerResource:GetPlayer( player ) or player
--    local hHero = player:GetAssignedHero()
--    return hHero:GetEntityIndex()
--end
--function GetNetTable( table, key )
--    key = tostring( key )
--    return CustomNetTables:GetTableValue( table, key )
--end
--function SetNetTable( table, key, value )
--    key = tostring( key )
--    value = type( value ) ~= 'table' and { value = value } or value
--    print('Set', table, key, value)
--    DeepPrintTable(value)
--    CustomNetTables:SetTableValue( table, key, value )
--end
--
--function GetUnitTarget(unit)
--    -- local iUnit   = unit:GetEntityIndex()
--    local value = GetNetTable( 'focus_target', unit:GetPlayerOwnerID() )
--    if value and value.value then
--        local target = EntIndexToHScript( value.value )
--        if IsValidEntity( target ) then 
--            return target
--        end
--    end
--    
--    return nil
--end

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
                ExecuteOrderFromTable {
                    OrderType    = DOTA_UNIT_ORDER_CAST_TARGET,
                    UnitIndex    = caster:entindex(),
                    TargetIndex  = target:entindex(),
                    AbilityIndex = order.entindex_ability,
                    Queue        = false
                }
                ability.customTargetCasting = false
            end
            
            return FILTER_EXECUTION_CANCEL
        end
    end
    
    return FILTER_EXECUTION_CONTINUE
end
