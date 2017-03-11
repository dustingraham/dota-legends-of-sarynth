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
    -- Subtle non-static spawn point.
    local targetPosition = self.spawnPoint
    if data.SpawnPositionJitter then
        targetPosition = targetPosition + RandomVector(RandomInt(20, 80))
    end
    
    local team = DOTA_TEAM_NEUTRALS
    if data.IsNpc then
        team = DOTA_TEAM_GOODGUYS
    end
    
    -- TODO: Listen to events the entity fires, entity should not know about spawn.
    local entity = CreateUnitByName(data.Creature, targetPosition, true, nil, nil, team)
    entity.spawn = self
    
    entity:SetIdleAcquire(false)
    
    if data.Gesture then
        entity:StartGesture(_G[data.Gesture])
    end
    
    if data.SpawnAngle then
        entity:SetAngles(0, data.SpawnAngle, 0)
    end
    
    if data.RandomScale then
        local scaleSet = entity:GetModelScale() + (math.random(-5, 10) / 100)
        entity:SetModelScale(scaleSet)
    end
    
    -- TODO: Source from unit data, override with spawn data.
    if data.AI then
        entity:AddNewModifier(nil, nil, data.AI, nil)
    end
    
    if data.Cosmetics then
        for _,name in pairs(data.Cosmetics) do
            CharacterPick:AddCosmetic(entity, name)
        end
    end
    
    if data.Unique then
        -- Debug('SpawnSystem', data.spawn_name)
        SpawnSystem:SetUnique(data.spawn_name, entity)
        entity.spawn_name = data.spawn_name
    end
    
    return entity
end

function Spawn:OnDeath()
    self.spawnNode:OnDeath(self)
end
