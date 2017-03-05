SpawnSystem = SpawnSystem or class({}, {
    spawnNodes = {},
    uniqueEntities = {},
})

--[[
    Hierarchy (Concept/Potential)
    - SpawnSystem (everything) - World of everything.
    - SpawnArea (3 groups) - Area of all spawns to avoid over crowding. (wolves, big sheep, small sheep)
    - SpawnGroup (2 spawns) - Coordinated group of similar spawns. (big sheep, small sheep)
    - Spawn (3 creatures) - Specific builder of multiple individual units. (multiple small sheep)
    - Creature (1 creature) - Individual unit.
    
    Want the ability to create three different units in a single group. Respawn group as a whole...?
    Want the ability for two different units to patrol together.
    
    Hierarchy (Current)
    - SpawnSystem - All nodes.
    - SpawnNode - Group of spawn locations with a single unit, and total units.
    - Spawn - Individual spawn instance, correlates with creature.
]]
function SpawnSystem:Init()
    local kvFileName = 'scripts/data/'..GetMapName()..'/spawns.kv'
    self.data = LoadKeyValues(kvFileName)
    
    if not self.data then
        Debug('SpawnSystem', '[ERROR] Likely KV Syntax Error: ', kvFileName)
        self.data = {}
        return
    end
    
    self:BuildSpawns()
    self:FirstSpawn()
    self:StartThinker()
end

function SpawnSystem:BuildSpawns()
    for key,spawnNodeData in pairs(self.data) do
        -- DeepPrintTable(self.data)
        -- print('------')
        -- print(key)
        -- print('------')
        -- DeepPrintTable(spawnNodeData)
        
        self.spawnNodes[key] = SpawnNode(key, spawnNodeData)
    end
end

function SpawnSystem:FirstSpawn()
    for _,spawnNode in pairs(self.spawnNodes) do
        spawnNode:FirstSpawn()
    end
end

function SpawnSystem:StartThinker()
    self.timer = Timers:CreateTimer(function()
        SpawnSystem:OnThink()
        return 1.0
    end)
end

function SpawnSystem:OnThink()
    for _,spawnNode in pairs(self.spawnNodes) do
        spawnNode:OnThink()
    end
end

function SpawnSystem:SetUnique(name, entity)
    self.uniqueEntities[name] = entity
end

function SpawnSystem:GetUnique(name)
    return self.uniqueEntities[name]
end

-- To split them out...
-- LoadKeyValues('scripts/data/quests/introduction.kv')
-- function MergeTables( t1, t2 ) for name,info in pairs(t2) do t1[name] = info end end
-- MergeTables(QuestService.data, LoadKeyValues(...))
