AiBase = AiBase or class({}, {
    name = 'AiBase',
    ACTION_IDLE = 'ActionIdle'
})

function AiBase:constructor(entity)
    self.entity = entity
    entity.ai = self
end

function AiBase:GetEntity()
    return self.entity
end

function AiBase:IsIdle()
    return self.state == AiBase.ACTION_IDLE
end

function AiBase:OnHeroDeath() end

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

function AiBase:DamageRadius(params)
    local pos = params.position or self:GetEntity():GetAbsOrigin()
    local radius = params.radius or 100
    local damage = params.damage or 100
    local damageType = params.damageType or DAMAGE_TYPE_MAGICAL
    local source = params.source or self:GetEntity()
    for _,target in pairs(self:FindHeroes(radius, pos)) do
        self:DealDamage(target, damage, damageType, source)
        if params.soundFx then
            EmitSoundOn(params.soundFx, target)
        end
        if params.popup then
            PopupDamage(target, damage)
        end
    end
end

function AiBase:DealDamage(target, damage, damageType, source)
    if not source then source = self:GetEntity() end
    if not damageType then damageType = DAMAGE_TYPE_MAGICAL end
    ApplyDamage({
        victim = target,
        attacker = source,
        damage = damage,
        damage_type = damageType
    })
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
