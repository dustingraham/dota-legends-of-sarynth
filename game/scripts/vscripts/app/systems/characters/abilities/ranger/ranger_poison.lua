ranger_poison = ranger_poison or class({})
local mod = ranger_poison

function mod:IsHidden()
    return false
end

function mod:IsDebuff()
    return true
end

function mod:OnCreated()
    local target = self:GetParent()
    self.damage_per_tick = 33 -- self:GetAbility():GetSpecialValueFor("var_damage_per_tick")
    self.tick_interval = 3 -- self:GetAbility():GetSpecialValueFor("var_tick_interval")
    if IsServer() then
        self:StartIntervalThink(self.tick_interval)
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
        damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DIRECTOR_EVENT,
        ability = self:GetAbility(),
    })
    PopupPoison(self:GetParent(), self.damage_per_tick)
end
