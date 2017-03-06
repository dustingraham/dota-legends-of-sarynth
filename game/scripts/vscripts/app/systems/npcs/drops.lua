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
    if killedUnit:IsCreature() then
        Drops:RollForDrops(killedUnit)
    end
end

function Drops:RollForDrops(killedUnit)
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
        -- TODO: This will increase the raw chance of at least 1 aquisition for multiples.
        for i = 1, max_drops do
            if RollPercentage(chance) then
                local item = CreateItem(item_name, nil, nil)
                local pos = killedUnit:GetAbsOrigin()
                local drop = CreateItemOnPositionSync(pos, item)
                local pos_launch = pos + RandomVector(RandomFloat(150, 200))
                item:LaunchLoot(false, 200, 0.75, pos_launch)
            end
        end
    end
end

if not Drops.initialized then
    Drops.initialized = true
    Event:Listen('Activate', Dynamic_Wrap(Drops, 'Activate'), Drops)
end
