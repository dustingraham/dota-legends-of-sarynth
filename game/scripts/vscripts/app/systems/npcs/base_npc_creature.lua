-- local creature = CDOTA_BaseNPC_Creature
local creature = CDOTA_BaseNPC

-- Clientside may require : C_DOTA_BaseNPC

function creature:CheckNpc()
    print('Checked: Creature', self:GetName(), self:GetClassname(), self:GetUnitName())
end

function creature:IsBoss()
    return self.isBoss
end

-- Reference concept.
--
--local entity = CBaseEntity
--function entity:CheckNpc()
--    print('Checked: Raw Entity', self:GetName(), self:GetClassname())
--end
--
--local npc = CDOTA_BaseNPC
--function npc:CheckNpc()
--    print('Checked: BaseNpc', self:GetName(), self:GetClassname(), self:GetUnitName())
--end
--
--local creature = CDOTA_BaseNPC_Creature
--function creature:CheckNpc()
--    print('Checked: Creature', self:GetName(), self:GetClassname(), self:GetUnitName())
--end
--
--local hero = CDOTA_BaseNPC_Hero
--function hero:CheckNpc()
--    print('Checked: Hero', self:GetName(), self:GetClassname(), self:GetUnitName())
--end

function creature:ParticleOn(name)
    if self.particles == nil then self.particles = {} end
    if self.particles[name] then return end
    self.particles[name] = ParticleManager:CreateParticle(
        name,
        PATTACH_ABSORIGIN_FOLLOW,
        self
    )
end

function creature:ParticleOff(name)
    if self.particles == nil then self.particles = {} end
    if not self.particles[name] then return end

    ParticleManager:DestroyParticle(self.particles[name], false)
    ParticleManager:ReleaseParticleIndex(self.particles[name])
    self.particles[name] = nil
end

function creature:ParticleOnForPlayer(name, pid)
    if self.playerParticles == nil then self.playerParticles = {} end
    if self.playerParticles[name] == nil then self.playerParticles[name] = {} end
    if self.playerParticles[name][pid] then return end
    self.playerParticles[name][pid] = ParticleManager:CreateParticleForPlayer(
        name,
        PATTACH_POINT_FOLLOW,
        self,
        PlayerResource:GetPlayer(pid)
    )
    -- Don't recall why setting the Ent is also useful/important?
    -- Errors on the shopkeeper since it does not have attach_hitloc
    -- Not a major deal, but perhaps figure it out.
    ParticleManager:SetParticleControlEnt(self.playerParticles[name][pid], 0, self, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetAbsOrigin(), true)
end

function creature:ParticleOffForPlayer(name, pid)
    if self.playerParticles == nil then self.playerParticles = {} end
    if not self.playerParticles[name] then return end
    if not self.playerParticles[name][pid] then return end

    ParticleManager:DestroyParticle(self.playerParticles[name][pid], false)
    ParticleManager:ReleaseParticleIndex(self.playerParticles[name][pid])
    self.playerParticles[name][pid] = nil
end

function creature:FindEnemyUnitsInRadius(position, radius, hData)
    if not self:IsNull() then
        local team = self:GetTeamNumber()
        local data = hData or {}
        local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_ENEMY
        local iType = data.type or DOTA_UNIT_TARGET_ALL
        local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
        local iOrder = data.order or FIND_ANY_ORDER
        return FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
    else return {} end
end

function creature:FindFriendlyUnitsInRadius(position, radius, hData)
    local team = self:GetTeamNumber()
    local data = hData or {}
    local iTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY
    local iType = data.type or DOTA_UNIT_TARGET_ALL
    local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
    local iOrder = data.order or FIND_ANY_ORDER
    return FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
end

function creature:FindAllUnitsInRadius(position, radius, hData)
    local team = self:GetTeamNumber()
    local data = hData or {}
    local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_BOTH
    local iType = data.type or DOTA_UNIT_TARGET_ALL
    local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
    local iOrder = data.order or FIND_ANY_ORDER
    return FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
end


