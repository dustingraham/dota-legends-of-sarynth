---
-- @type SpawnNode
SpawnNode = SpawnNode or class({
    -- Defaults
    SpawnPoints = "", -- Entity names to spawn.
    RoamPath = "", -- Entity names to roam.
    RoamPattern = "None", -- None, Circular, Reverse, Random
    Creature = nil, -- NPC creature name.
    MaxCount = 1, -- Max to spawn.
    Chance = 100, -- Chance to spawn each tick.
    OnInitSpawn = 1, -- How many to spawn on game init.
    --    InitialDelay = 0,
    --    RespawnDelay = 0,
})

---
-- @function [parent=#SpawnNode] constructor
-- @param self
function SpawnNode:constructor(key, params)
    self.spawn_name = key
    self.Spawns = {}

    TableMerge(self, params)
    self.SpawnPoints = Split(self.SpawnPoints)
    self.RoamPath = Split(self.RoamPath)
end

---
-- @function [parent=#SpawnNode] FirstSpawn
-- @param self
function SpawnNode:FirstSpawn()
    for i = 1, self.OnInitSpawn do
        table.insert(self.Spawns, Spawn(self))
    end
end

---
-- @function [parent=#SpawnNode] OnThink
-- @param self
function SpawnNode:OnThink()
    -- Improve: Higher chance with fewer alive?
    -- Improve: Respawn time? Initial Delay?
    if #self.Spawns < self.MaxCount then
        if RollPercentage(self.Chance) then
            local randomDelay = RandomInt(0,80) / 100
            Timers:CreateTimer(randomDelay, function()
                table.insert(self.Spawns, Spawn(self))
            end)
        end
    end
end

---
-- @function [parent=#SpawnNode] OnDeath
-- @param self
-- @param #string spawn
function SpawnNode:OnDeath(spawn)
    local delay = self.RespawnDelay or 0
    Timers:CreateTimer(delay, function()
        for k,v in ipairs(self.Spawns) do
            if spawn == v then
                table.remove(self.Spawns, k)
                break
            end
        end
    end)
end
