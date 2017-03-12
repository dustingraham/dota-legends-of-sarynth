Wrappers = Wrappers or {}

-- Convenience wrapper that puts a single value into a table if necessary.
local valueKey = 'customSoloValue'
function Wrappers.SetNetTable(table, key, value)
    key = tostring(key)
    if type(value) ~= 'table' then
        value = { [valueKey] = value }
    end
    CustomNetTables:SetTableValue(table, key, value)
end
function Wrappers.GetNetTable(table, key)
    key = tostring(key)
    local value = CustomNetTables:GetTableValue(table, key)
    if value and value[valueKey] then
        value = value[valueKey]
    end
    return value
end

---
-- Get entity handle for focus target for hero
-- 
function Wrappers.GetFocusTarget(forHero)
    local value = Wrappers.GetNetTable('focus_target', forHero:GetPlayerOwnerID())
    
    -- Why is this suddenly needed...?
    if not value then return nil end
    
    local target = EntIndexToHScript(value)
    if IsValidEntity( target ) then 
        return target
    end
    
    return nil
end

function Wrappers.FocusTargetAbility(spell)
--    local castFilterResult = spell.CastFilterResult 
--    function spell:CastFilterResult()
--        
--    end
    
--    function spell:Init()
----        local tteam = self:GetAbilityTargetTeam()
----        local ttype = self:GetAbilityTargetType()
----        local tflag = self:GetAbilityTargetFlags()
--        local tteam = false
--        print('SpellInit', tteam)
--        self.initialized = true
--    end
    
    if spell.UnitFilter ~= nil then
        Debug('Wrappers', 'Found non-nil UnitFilter in ability wrap.')
    end
    
    function spell:UnitFilter(target)
        -- return UF_SUCCESS
        return UnitFilter(
            target,
            self.target_team,
            self.target_type,
            self.target_flag,
            self:GetCaster():GetTeamNumber()
        )
    end
    
    -- Pre-wrapped GetBehavior call.
    local getBehavior = spell.GetBehavior
    
    local debugState = true
    local debugValue = nil
    
    function spell:GetBehavior()
--        if not self.initialized then
--            self:Init()
--        end
        
        local caster  = self:GetCaster()
        local target = Wrappers.GetFocusTarget(caster)
        
        local behavior
        if getBehavior then
            -- Pre-wrapped GetBehavior call.
            behavior = getBehavior(self)
        else
            -- Parent class, default call
            behavior = self.BaseClass.GetBehavior(self)
        end
        
        -- Debugging...
        if target ~= debugValue then
            print('New target')
            debugValue = target
            debugState = true
        end
        
        if not self.customTargetCasting and target then
            local filter = self:UnitFilter(target)
            if filter == UF_SUCCESS then
                if debugState then
                    debugState = false
                    print('[Behavior] Set Ability to NO_TARGET')
                end
                behavior = behavior 
                    - DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
                    + DOTA_ABILITY_BEHAVIOR_NO_TARGET
            end
        end
        
        if debugState then
            debugState = false
            print('Set To Unit Target')
        end
        
        return behavior
    end
    
    -- UNIT_TARGET Filter
    function spell:CastFilterResultTarget(target)
        local caster = self:GetCaster()
        return self:UnitFilter(target)
    end
    
    -- NO_TARGET Filter
    function spell:CastFilterResult()
        print('[SPELL] NO_TARGET Cast Filter Check')
        
        local caster = self:GetCaster()
        
        local target = Wrappers.GetFocusTarget(caster)
        if not target then
            return UF_FAIL_CUSTOM
        end
        
        return self:UnitFilter(target)
    end
    
    local getCursorTarget = spell.GetCursorTarget
    function spell:GetCursorTarget()
        -- local goodTarget = getCursorTarget(self)
        local goodTarget = self.BaseClass.GetCursorTarget(self)
        
        local testTarget =  Wrappers.GetFocusTarget(self:GetCaster())
        if testTarget ~= goodTarget then
            print('UNMATCHED TARGETS')
            print('Actual: ', goodTarget)
            print('Focus: ', testTarget)
        end
        
        return goodTarget
    end
    
    function spell:UseCustomTarget()
        return true
    end
end

function Wrappers.OnThinkExampleAbility(ability)
    -- Example Overwrite Concept
    local onChannelThink = ability.OnChannelThink
    function ability:OnChannelThink(interval)
        if interval == 0 then
            -- Do something snazzy
        end
        if onChannelThink then
            -- Default Thinker
            onChannelThink(self, interval)
        end
    end
end
