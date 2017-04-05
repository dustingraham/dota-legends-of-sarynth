Wrappers = Wrappers or {
    useFocusTarget = true
}

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

function Wrappers.ToggleFocusTargetUsage(PlayerID, useFocusTarget)
    -- For client usage
    Wrappers.SetNetTable('settings', 'setting'..PlayerID, useFocusTarget)
    -- For server usage
    Wrappers.useFocusTarget = useFocusTarget
end

function Wrappers.FocusTargetAbility(spell)

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
    function spell:GetBehavior()
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

        -- Check whether Focus Target is toggled.
        Wrappers.useFocusTarget = Wrappers.GetNetTable('settings', 'setting'..caster:GetPlayerOwnerID()) == 1
        if not Wrappers.useFocusTarget then
            -- Toggled Off.
            return behavior
        end

        -- If we have a focus target, and we're not here in the
        -- special unit filter execution call, then set the
        -- behavior to no target.
        if not self.customTargetCasting and target then
            if self:UnitFilter(target) == UF_SUCCESS then
                behavior = behavior
                - DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
                + DOTA_ABILITY_BEHAVIOR_NO_TARGET
            end
        end

        return behavior
    end

    -- UNIT_TARGET Filter
    function spell:CastFilterResultTarget(target)
        return self:UnitFilter(target)
    end

    -- NO_TARGET Filter
    function spell:CastFilterResult()
        local caster = self:GetCaster()
        local target = Wrappers.GetFocusTarget(caster)
        if not target then
            return UF_FAIL_CUSTOM
        end

        return self:UnitFilter(target)
    end

    -- This is expected behavior. Using default GetCursorTarget.
    --    local getCursorTarget = spell.GetCursorTarget
    --    function spell:GetCursorTarget()
    --        -- local goodTarget = getCursorTarget(self)
    --        local goodTarget = self.BaseClass.GetCursorTarget(self)
    --
    --        local testTarget =  Wrappers.GetFocusTarget(self:GetCaster())
    --        if testTarget ~= goodTarget then
    --            print('UNMATCHED TARGETS')
    --            print('Actual: ', goodTarget)
    --            print('Focus: ', testTarget)
    --        end
    --
    --        return goodTarget
    --    end

    function spell:UseCustomTarget()
        return Wrappers.useFocusTarget
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

-- Warrior
function Wrappers.AbilityBasicsWarrior(spell)
    -- Add basic stuff like range.
    function spell:GetCastRange()
        return 150
    end
    function spell:GetMaxLevel()
        return 1
    end
    function spell:GetBehavior()
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT
    end

    --function spell:GetAbilityTargetTeam()
    --    print('GetAbilityTargetTeam')
    --    return DOTA_UNIT_TARGET_TEAM_ENEMY
    --end
    --function spell:GetAbilityTargetType()
    --    print('GetAbilityTargetType')
    --    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    --end
    --function spell:GetAbilityDamageType()
    --    print('GetAbilityDamageType')
    --    return DAMAGE_TYPE_MAGICAL
    --end
end
