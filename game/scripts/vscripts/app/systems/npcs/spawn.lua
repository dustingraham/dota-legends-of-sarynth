Spawn = Spawn or class({})

function Spawn:constructor(spawnNode)
    self.spawnNode = spawnNode

    -- TODO: Cache this in SpawnNode
    -- TODO: make function in spawn node to get random spawn location.
    -- TODO: Avoid picking points that already have units.

    local key = spawnNode.SpawnPoints[RandomInt(1,#spawnNode.SpawnPoints)]
    Debug('Spawn', key)

    local targetEntity = Entities:FindByName(nil, key)
    if not targetEntity then
        Debug('Spawn', '[ERROR] Could not find entity by name:', key)
        return
    end

    self.spawnPoint = targetEntity:GetAbsOrigin()

    -- TODO: Stupid bad, but easy, trying to ensure unique...
    for i = 1, 10 do
        -- Make an attempt to find a different node.
        for _,spawn in pairs(spawnNode.Spawns) do
            if spawn.spawnPoint == self.spawnPoint then
                key = spawnNode.SpawnPoints[RandomInt(1,#spawnNode.SpawnPoints)]
                self.spawnPoint = Entities:FindByName(nil, key):GetAbsOrigin()
            end
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

    -- Conceptual.
    -- Can have problem of spawning into the water if used everywhere.
    -- Also affects heroes and teleport pads if applied 100%.
    if data.Creature == 'webbed_spidy_bubble' then
        if GridNav:IsNearbyTree(targetPosition, 1000, true) then
            local closest
            local closestDistance
            for _,tree in pairs(GridNav:GetAllTreesAroundPoint(targetPosition, 1000, true)) do
                local dist = (tree:GetAbsOrigin() - targetPosition):Length()
                if closest == nil or dist < closestDistance then
                    closest = tree
                    closestDistance = dist
                end
            end
            targetPosition = closest:GetAbsOrigin()
        end
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
        entity:AddNewModifier(entity, nil, data.AI, nil)
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

    local unitData = GameUnits[data.Creature]
    if unitData.Glow then
        self:MakeGlow(entity, unitData.Glow)
    end

    return entity
end

function Spawn:OnDeath(ai)
    self.spawnNode:OnDeath(self)
    if ai and ai:GetParent() and ai:GetParent().GlowParticle then
        Debug('Spawn', 'Releasing glow on death.')
        local idx = ai:GetParent().GlowParticle
        ParticleManager:DestroyParticle(idx, false)
        ParticleManager:ReleaseParticleIndex(idx)
    end
end

function Spawn:MakeGlow(entity, name)
    entity.GlowParticle = ParticleManager:CreateParticle(name, PATTACH_OVERHEAD_FOLLOW, entity)

    -- Attempt, but no attach_hitloc on bears....
    --if name == 'particles/units/druids/protector/druids_protector_orb.vpcf' then
    --    -- Special case attachments...
    --    local idx = ParticleManager:CreateParticle(name, PATTACH_ABSORIGIN_FOLLOW, entity)
    --    ParticleManager:SetParticleControlEnt(idx, 1, entity, PATTACH_POINT_FOLLOW, "attach_mouth", entity:GetAbsOrigin(), true)
    --    entity.GlowParticle = idx
    --else
end
