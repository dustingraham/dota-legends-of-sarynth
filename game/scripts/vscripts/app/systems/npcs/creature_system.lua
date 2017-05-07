---
-- Specifically designed for dark boss.
--
-- @type CreatureSystem
CreatureSystem = CreatureSystem or class({})

function CreatureSystem:Activate()
    Filters:OnModifierGainedFilter(Dynamic_Wrap(CreatureSystem, 'OnModifierGainedFilter'), CreatureSystem)
end

function CreatureSystem:OnModifierGainedFilter(event)
    local parent = EntIndexToHScript(event.params.entindex_parent_const)

    --local caster
    --if event.params.entindex_caster_const then
    --    caster = EntIndexToHScript(event.params.entindex_caster_const)
    --end

    --local ability
    --if event.params.entindex_ability_const then
    --    ability = EntIndexToHScript(event.params.entindex_ability_const)
    --end

    -- 1) If this is the boss, don't take stuns.
    if parent:GetUnitName() == 'dark_boss' then
        local stuns = {
            ranger_concussion = true,
            mage_ice_shocked = true,
            rogue_incapacitated = true,
            sorcerer_blasted = true,
            warrior_bashed = true,
        }
        if stuns[event.params.name_const] then
            Debug('CreatureSystem', 'Dark Boss Stun Aversion')
            return false
        end
    end

    -- 2) If this is a summon, don't take armor.
    -- Stopped using this because auras suck and re-apply every frame if denied.
    -- DG Suggested GetAuraEntityReject but would need lua modifier.
    -- Still appears in the javascript buffs.
    --if parent:GetUnitName() == 'dark_boss_summons' then
    --    if event.params.name_const == 'shard_armor_aura_effect' then
    --        -- Don't take armor modifier.
    --        --Debug('CreatureSystem', 'Avoid armor aura on summons.')
    --        return false
    --    end
    --end

    --if event.params.name_const == 'ai_basic_sheep' then return end
    --if event.params.name_const == 'ai_aggro_leash' then return end

    -- DeepPrintTable(event)

    --local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)

    return true
end

Event:BindActivate(CreatureSystem)
