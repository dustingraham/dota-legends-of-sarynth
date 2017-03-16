ranger_poison = ranger_poison or class({})
local mod = ranger_poison

function mod:IsHidden()
    return false
end

function mod:IsDebuff()
    return true
end

function mod:OnCreated(params)
    -- local target = self:GetParent()
    if IsServer() then
        self.damage_per_tick = params.damage
        self:StartIntervalThink(params.interval)
    end
end

function mod:OnDestroy()
    -- ParticleManager:DestroyParticle(self.particle_flame, false)
end

function mod:OnIntervalThink()
    ApplyDamage({
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.damage_per_tick,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
        ability = self:GetAbility(),
    })
    PopupPoison(self:GetParent(), self.damage_per_tick)
end
