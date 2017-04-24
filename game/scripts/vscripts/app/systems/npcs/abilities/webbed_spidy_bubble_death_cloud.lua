webbed_spidy_bubble_death_cloud = webbed_spidy_bubble_death_cloud or class({})
local mod = webbed_spidy_bubble_death_cloud

function mod:IsHidden()
    return false
end

function mod:IsDebuff()
    return true
end

function mod:IsPurgable()
    return true
end

function mod:GetTexture()
    return 'alchemist_acid_spray'
end

function mod:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function mod:GetModifierMoveSpeedBonus_Percentage()
    return -10
end

function mod:OnCreated(kv)
    if IsServer() then
        self:SetStackCount(1)
        self.lastDamageTick = 0
        local damageTable = {
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = math.random(20,40),
            damage_type = DAMAGE_TYPE_MAGICAL
        }
        ApplyDamage(damageTable)
        PopupPoison(self:GetParent(), damageTable.damage)
    end
end

function mod:OnRefresh(kv)
    -- print('Is Server: ', IsServer())
    if IsServer() then
        -- print('Modifier Parent: ', self:GetParent():GetName())
        -- print('Modifier Caster: ', self:GetCaster():GetName())
        self:IncrementStackCount()
        self.lastDamageTick = self.lastDamageTick + math.random(20,40)
        local damageTable = {
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            --damage = self:GetStackCount() * math.random(20,40),
            damage = self.lastDamageTick,
            damage_type = DAMAGE_TYPE_MAGICAL
        }
        ApplyDamage(damageTable)
        PopupPoison(self:GetParent(), damageTable.damage)
    end
end
