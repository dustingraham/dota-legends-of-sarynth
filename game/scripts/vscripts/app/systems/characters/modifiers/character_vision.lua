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
    self:StartIntervalThink(1/32)
  end
end

function character_vision:IsHidden()
  return self:GetStackCount() == 1
end

function character_vision:OnIntervalThink()
    local caster = self:GetParent()
    if caster:IsAlive() then
        self:SetStackCount(0)
        AddFOWViewer(caster:GetTeamNumber(), caster:GetAbsOrigin(), 1000, 2/32, false)
    else
        self:SetStackCount(1)
    end
end
