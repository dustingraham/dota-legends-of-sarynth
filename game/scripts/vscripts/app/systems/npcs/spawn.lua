Spawn = Spawn or class({})

function Spawn:constructor(spawnNode)
    self.spawnNode = spawnNode
    
    -- TODO: Cache this in SpawnNode
    -- TODO: make function in spawn node to get random spawn location.
    -- TODO: Avoid picking points that already have units.
    
    local key = spawnNode.SpawnPoints[RandomInt(1,#spawnNode.SpawnPoints)]
    Debug('Spawn', key)
    self.spawnPoint = Entities:FindByName(nil, key):GetAbsOrigin()
    
    -- Make one attempt to find a different node.
    for _,spawn in pairs(spawnNode.Spawns) do
        if spawn.spawnPoint == self.spawnPoint then
            key = spawnNode.SpawnPoints[RandomInt(1,#spawnNode.SpawnPoints)]
            self.spawnPoint = Entities:FindByName(nil, key):GetAbsOrigin()
        end
    end
    
    self.entity = self:Spawn(spawnNode)
end

function Spawn:Spawn(data)
    -- Subtle non-static spawn point. TODO: Param to disable?
    local targetPosition = self.spawnPoint + RandomVector(RandomInt(20, 60))
    
    team = DOTA_TEAM_NEUTRALS
    if data.IsNpc then
        team = DOTA_TEAM_GOODGUYS
    end
    
    -- TODO: Listen to events the entity fires, entity should not know about spawn.
    local entity = CreateUnitByName(data.Creature, targetPosition, true, nil, nil, team)
    entity.spawn = self
    
    -- print('['..entity:GetUnitName()..'] ',entity:ShouldIdleAcquire(),' default: ',data.IdleAcquire)
    entity:SetIdleAcquire(data.IdleAcquire == 1)
    if data.AcquisitionRange then
        entity:SetAcquisitionRange(data.AcquisitionRange)
    end
    
    if data.Gesture then
        entity:StartGesture(_G[data.Gesture])
    end
    
    if data.SpawnAngle then
        entity:SetAngles(0, data.SpawnAngle, 0)
    end
    
    local scaleSet = entity:GetModelScale() + (math.random(-5, 10) / 100)
    entity:SetModelScale(scaleSet)
    
    -- TODO: Source from unit data, override with spawn data.
    if data.AI then
        entity:AddNewModifier(nil, nil, data.AI, nil)
    end
    
    if data.Unique then
        SpawnSystem:SetUnique(data.Unique, entity)
    end
    
    return entity
end

function Spawn:OnDeath()
    self.spawnNode:OnDeath(self)
end
