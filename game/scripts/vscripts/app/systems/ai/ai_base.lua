AiBase = AiBase or class({}, {
    name = 'AiBase'
})

function AiBase:constructor(entity)
    self.entity = entity
    entity.ai = self
end

function AiBase:GetEntity()
    return self.entity
end


function AiBase:FindHeroes(range, sourcePosition)
    if self:GetEntity():IsNull() then return {} end
    sourcePosition = sourcePosition or self:GetEntity():GetAbsOrigin()
    return FindUnitsInRadius(
        self:GetEntity():GetTeam(),
        sourcePosition,
        nil,
        range,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
end

function AiBase:OnDeath()
    local entity = self:GetEntity()
    if entity and entity.GlowParticle then
        self:Debug('Releasing glow on death.')
        local idx = entity.GlowParticle
        ParticleManager:DestroyParticle(idx, false)
        ParticleManager:ReleaseParticleIndex(idx)
    end
end

function AiBase:Debug(...)
    Debug(self.name, ...)
end
