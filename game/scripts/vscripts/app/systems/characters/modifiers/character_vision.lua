character_vision = character_vision or class({})

function character_vision:GetIntrinsicModifierName()
  return "character_vision"
end

function character_vision:IsPassive()
  return true
end

function character_vision:IsPurgable()
  return false
end

function character_vision:RemoveOnDeath()
  return false
end

function character_vision:OnCreated()
  if IsServer() then
    self.visionRange = 1000
    self:StartIntervalThink(1/32)
  end
end

function character_vision:IsHidden()
  return true
end

function character_vision:OnIntervalThink()
    local caster = self:GetParent()
    if caster:IsAlive() then
        self:SetStackCount(0)
        AddFOWViewer(caster:GetTeamNumber(), caster:GetAbsOrigin(), self.visionRange, 2/32, false)
    else
        self:SetStackCount(1)
    end
end

function character_vision:ReduceVision()
    self.visionRange = 300
end
function character_vision:RestoreVision()
    self.visionRange = 1000
end
