character_vision = character_vision or class({})
local mod = character_vision

function mod:IsPassive()
  return true
end

function mod:IsPurgable()
  return false
end

function mod:RemoveOnDeath()
  return false
end

function mod:OnCreated()
  if IsServer() then
    self.visionRange = 1000
    self:StartIntervalThink(1/32)
  end
end

function mod:IsHidden()
  return true
end

function mod:OnIntervalThink()
    local caster = self:GetParent()
    if caster:IsAlive() then
        self:SetStackCount(0)
        AddFOWViewer(caster:GetTeamNumber(), caster:GetAbsOrigin(), self.visionRange, 2/32, false)
    else
        self:SetStackCount(1)
    end
end

function mod:ReduceVision()
    self.visionRange = 300
end
function mod:RestoreVision()
    self.visionRange = 1000
end

--- Focus Target

function mod:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ATTACKED,
    }
end

function mod:UpdateFocusTarget(newFocusTarget)
    Wrappers.SetNetTable('focus_target', self:GetParent():GetPlayerOwnerID(), newFocusTarget:GetEntityIndex())
    CustomGameEventManager:Send_ServerToPlayer(self:GetParent():GetPlayerOwner(), 'focus_target_updated', { id = newFocusTarget:GetEntityIndex() })
end

function mod:OnAttack(event)
    if self:GetParent() ~= event.attacker then return end
    local target = Wrappers.GetFocusTarget(self:GetParent())
    if not IsValidEntity(target) or not target:IsAlive() then
        self:UpdateFocusTarget(event.target)
    end
end

function mod:OnAttacked(event)
    if self:GetParent() ~= event.target then return end
    local target = Wrappers.GetFocusTarget(self:GetParent())
    if not IsValidEntity(target) or not target:IsAlive() then
        self:UpdateFocusTarget(event.attacker)
        --Wrappers.SetNetTable('focus_target', self:GetParent():GetPlayerOwnerID(), event.attacker:GetEntityIndex())
        --CustomGameEventManager:Send_ServerToPlayer(self:GetParent():GetPlayerOwner(), 'focus_target_updated', { id = event.attacker:GetEntityIndex() })
    end
end
