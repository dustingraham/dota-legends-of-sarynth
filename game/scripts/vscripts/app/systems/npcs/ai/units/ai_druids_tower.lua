ai_druids_tower = ai_druids_tower or class({})
local ai = ai_druids_tower

ai.ACTION_LOCKED = 'ActionLocked'
ai.ACTION_UNLOCKED = 'ActionUnlocked'
ai.countUnlocked = 0

function ai:OnCreated(keys)
    if IsServer() then
        Debug('AiDruidsTower', 'OnCreated')
        self.state = ai.ACTION_LOCKED
        self.protectorName = self:GetParent().spawn.spawnNode.Protector
        self:StartIntervalThink(1.0)
        self:SetLookLocked()
    end
end

-----------------------------------------------------------------------------

function ai:SetLookLocked()
    self:ParticleOff()
    self:UpdateLevelTo(1, function()
        self:ParticleBad()
    end)
end
function ai:SetLookUnlocked()
    self:ParticleOff()
    self:UpdateLevelTo(6, function()
        self:ParticleMax()
    end)
end

function ai:UpdateLevelTo(id, callback)
    local params = {
        duration = 9999, -- 2.5 hr limit...
        activity = ACT_DOTA_CAPTURE,
        rate = 0.15,
        translate = 'level'..id, -- self.activityLevel
    }
    if self.isAnimating then
        EndAnimation(self:GetParent())
        -- self:ModPurge()
        Timers(0.25, function()
            self.isAnimating = true
            StartAnimation(self:GetParent(), params)
            callback()
        end)
    else
        self.isAnimating = true
        StartAnimation(self:GetParent(), params)
        callback()
    end
end

-----------------------------------------------------------------------------
-- For testing, just watch for hero then unlock.
function ai:ActionLocked()
    local units = FindUnitsInRadius(
    self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil,
    600, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER, false
    )
    if #units > 0 then
        --self:TransitionToUnlocked()
        return true
    end
end

function ai:TransitionToUnlocked()
    Debug('AiDruidsTower', 'Unlocking', self:GetParent().spawn.spawnNode.spawn_name)
    self.state = ai.ACTION_UNLOCKED
    self:SetLookUnlocked()
end
function ai:ActionUnlocked() end

-----------------------------------------------------------------------------
-- Old Stuff

-----------------------------------------------------------------------------

-- ACT_DOTA_ATTACK - Appears to be the fully closed state.
-- ACT_DOTA_IDLE+level1+showcase = weird fast moving, test!
-- ACT_DOTA_CAPTURE - just the ball
-- ACT_DOTA_CAPTURE+level1 - various modes of open
-- ACT_DOTA_CONSTANT_LAYER+level1 - appears similar to capture.
-- ACT_DOTA_IDLE+level2+showcase - appears to be the transition from level1 to level2?

-----------------------------------------------------------------------------

function ai:IsHidden() return true end

function ai:CheckState()
    return {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
    }
end

function ai:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
    }
end

function ai:OnIntervalThink()
    Dynamic_Wrap(ai, self.state)(self)
end

------
---
---
function ai:OnDeath(event)
    -- Only care about
    if self.state ~= ai.ACTION_LOCKED then return end
    if event.unit:GetUnitName() ~= self.protectorName then return end

    Debug('AiDruidsTower', 'Protector died, transition to unlocked.')
    self:TransitionToUnlocked()

    local pos = self:GetParent():GetAbsOrigin()
    Timers:CreateTimer(0.25, function()
        ScreenShake(pos, 1.5, 400, 3, 2000, 0, true)
    end)

    -- Check if all 3 have unlocked, open the boss area.
    ai.countUnlocked = ai.countUnlocked + 1
    if ai.countUnlocked == 3 then
        Debug('AiDruidsTower', 'All unlocked, open boss area.')

        local door = Entities:FindByName(nil, 'druids_building_door')
        door:SetAbsOrigin(door:GetAbsOrigin() - Vector(0,0,512))
        -- Remove the simple obstructions
        for _,obstruction in pairs(Entities:FindAllByName('druids_door_obstruction')) do
            obstruction:SetEnabled(false, false)
        end
    end
end

------------------------------------------------------
-- Misc Helpers
--

function ai:ParticleBad()
    self:ParticleOn('particles/world_tower/tower_upgrade/ti7_dire_tower_orb.vpcf')
end
function ai:ParticleGood()
    self:ParticleOn('particles/world_tower/tower_upgrade/ti7_radiant_tower_orb.vpcf')
end
function ai:ParticleMax()
    self:ParticleOn('particles/world_tower/tower_upgrade/ti7_radiant_tower_lvl11_orb.vpcf')
end
function ai:ParticleOn(particleName)
    if self.activeParticle == nil then
        --Debug('AiDruidsTower', 'Particle on...', particleName)
        self.activeParticle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    end
end

function ai:ParticleOff()
    if self.activeParticle then
        ParticleManager:DestroyParticle(self.activeParticle, false)
        ParticleManager:ReleaseParticleIndex(self.activeParticle)
        self.activeParticle = nil
    end
end

function ai:EnsureParticle()
    if self.particleCreated == nil then
        self.particleCreated = true
        Debug('AiDruidsTower', 'Creating particle...')
        ParticleManager:ReleaseParticleIndex(ParticleManager:CreateParticle(
        'particles/world_tower/tower_upgrade/ti7_radiant_tower_lvl11_orb.vpcf',
        --'particles/world_tower/tower_upgrade/ti7_radiant_tower_orb.vpcf',
        PATTACH_ABSORIGIN_FOLLOW,
        self:GetParent()
        ))
    end
end

function ai:ModPurge()
    for _,modifier in pairs(self:GetParent():FindAllModifiers()) do
        if modifier ~= self then
            -- Proper Reset?
            Debug('AiDruidsTower', 'Removing: '..modifier:GetName())
            modifier:Destroy()
        end
    end
end
