druids_boss_fire = druids_boss_fire or class({})
local mod = druids_boss_fire

function mod:IsHidden()
    return false
end

function mod:IsDebuff()
    return true
end

function mod:IsPurgable()
    return false
end

function mod:GetTexture()
    return 'nevermore_shadowraze3_demon'
end

function mod:OnCreated(kv)
    if IsServer() then
        self:SetStackCount(1)
        -- Initial damage 800-1200
        local damage = math.random(800,1200)
        ApplyDamage({
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL
        })
        PopupDamage(self:GetParent(), damage)
    end
end

function mod:OnRefresh(kv)
    if IsServer() then
        -- print('Modifier Parent: ', self:GetParent():GetName())
        -- print('Modifier Caster: ', self:GetCaster():GetName())
        -- Refresh damage (standing in the fire) 1200-1800
        local damage = math.random(1200,1800)
        ApplyDamage({
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL
        })
        PopupDamage(self:GetParent(), damage)
    end
end
