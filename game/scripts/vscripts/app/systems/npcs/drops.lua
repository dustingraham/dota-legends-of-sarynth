---
--@type Drops
Drops = Drops or class({})

function Drops:Activate()

    local kvFileName = 'scripts/data/'..GetMapName()..'/droptable.kv'
    self.DropTable = LoadKeyValues(kvFileName)

    if not self.DropTable then
        Debug('Drops', '[ERROR] Likely KV Syntax Error: ', kvFileName)
        self.DropDable = {}
        return
    end

    ListenToGameEvent('entity_killed', Dynamic_Wrap(Drops, 'OnEntityKilled'), Drops)
end

function Drops:OnEntityKilled(event)
    local killedUnit = EntIndexToHScript(event.entindex_killed)
    local attacker
    if event.entindex_attacker ~= nil then
        attacker = EntIndexToHScript(event.entindex_attacker)
    end
    if attacker and attacker:IsHero() and killedUnit:IsCreature() then
        Drops:RollForDrops(killedUnit, attacker)
    end
end

function Drops:RollForDrops(killedUnit, hero)
    local DropInfo = Drops.DropTable[killedUnit:GetUnitName()]
    if not DropInfo then return end
    for _,ItemTable in pairs(DropInfo) do
        -- Check for ItemSet
        local item_name
        if ItemTable.ItemSet then
            local total = 0
            for _,chance in pairs(ItemTable.ItemSet) do
                total = total + chance
            end
            local roll = RandomInt(1,total)
            for set_item,chance in pairs(ItemTable.ItemSet) do
                if roll <= chance then
                    item_name = set_item
                    break
                else
                    roll = roll - chance
                end
            end
        else
            item_name = ItemTable.Item
        end

        local chance = ItemTable.Chance or 100
        local max_drops = ItemTable.Multiple or 1

        -- Check if this is a quest item...
        if ItemTable.Quest then
            local quest = QuestService:GetPlayerQuest(hero:GetPlayerOwnerID(), ItemTable.Quest)
            if quest then
                -- TODO: Multi-objective will drop if only one is filled.
                -- TODO: Some quests like the dark priest need one-per-player...
                if quest:IsComplete() then
                    -- Avoid dropping if is complete.
                    max_drops = 0
                end
            else
                -- Avoid dropping a quest item.
                max_drops = 0
            end
        end

        -- TODO: This will increase the raw chance of at least 1 aquisition for multiples.
        for i = 1, max_drops do
            --local rolledSuccess = RollPercentage(chance)
            local roll = math.random(100)
            Debug('Drops', 'Roll: ', roll, ' Chance: ', chance, ' Success: ', chance >= roll)
            if chance >= roll then
                local item = CreateItem(item_name, nil, nil)
                local pos = killedUnit:GetAbsOrigin()
                local drop = CreateItemOnPositionSync(pos, item)
                local pos_launch = pos + RandomVector(RandomFloat(150, 200))
                self:DropItem(item, pos_launch, drop)
            end
        end
    end
end

function Drops:DropItem(item, pos_launch, drop)
    -- Set a 60 second timer.
    local expires = 60
    local warning = 20

    -- Early warning system.
    Timers:CreateTimer(expires - warning, function()
        -- Check if picked up?
        if not drop:IsNull() then
            local particle = ParticleManager:CreateParticle('particles/effects/loot_expire/loot_expire.vpcf', PATTACH_ABSORIGIN, drop)
            ParticleManager:SetParticleControl(particle, 0, pos_launch)
            ParticleManager:ReleaseParticleIndex(particle)
        end
    end)

    -- If it's still around at the end of the day.
    Timers:CreateTimer(expires, function()
        if not drop:IsNull() then
            item:RemoveSelf()
            drop:RemoveSelf()
        end
    end)

    -- And fire away!
    item:LaunchLoot(false, 200, 0.75, pos_launch)
end

if not Drops.initialized then
    Drops.initialized = true
    Event:Listen('Activate', Dynamic_Wrap(Drops, 'Activate'), Drops)
end
