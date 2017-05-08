ai_druids_tower = ai_druids_tower or class({})
local ai = ai_druids_tower

--function ai:DeclareFunctions()
--    return {
--        MODIFIER_EVENT_ON_DEATH,
--        MODIFIER_EVENT_ON_TAKEDAMAGE,
--        MODIFIER_EVENT_ON_ATTACK_ALLIED,
--    }
--end

ai.ACTION_IDLE = 'ActionIdle'
ai.ACTION_AGGRO = 'ActionAggro'
ai.ACTION_RETURN = 'ActionReturn'

function ai:OnCreated(keys)
    if IsServer() then
        Debug('AiDruidsTower', 'OnCreated')
        self.state = ai.ACTION_IDLE
        self.aggroCycle = 0
        self.detectRange = 600
        self:StartIntervalThink(1.0)

        self:SetLook1()
    end
end

function ai:IncrementAggroCycle()
    if self.aggroCycle < 6 then self.aggroCycle = self.aggroCycle + 1 end
    self.activityLevel = 'level'..self.aggroCycle
    Debug('AiDruidsTower', 'ActivityLevel', self.activityLevel)
end

-----------------------------------------------------------------------------

function ai:SetLook1()
    -- Bad Particle
    -- level 1
    self:ParticleOff()
    self:UpdateLevelTo(1, function()
        --self:ParticleBad()
        self:ParticleGood()
    end)
end
function ai:SetLook2()
    --self:ParticleOff()
    self:UpdateLevelTo(3, function()
        --self:ParticleGood()
        --self:ParticleBad()
    end)
end
function ai:SetLook3()
    self:ParticleOff()
    self:UpdateLevelTo(6, function()
        self:ParticleBad()
        --self:ParticleMax()
    end)
end

function ai:UpdateLevelTo(id, callback)
    local params = {
        duration = 9999, -- 2.5 hr limit...
        activity = ACT_DOTA_CAPTURE,
        rate = 0.10,
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

-- ACT_DOTA_ATTACK - Appears to be the fully closed state.
-- ACT_DOTA_IDLE+level1+showcase = weird fast moving, test!
-- ACT_DOTA_CAPTURE - just the ball
-- ACT_DOTA_CAPTURE+level1 - various modes of open
-- ACT_DOTA_CONSTANT_LAYER+level1 - appears similar to capture.
-- ACT_DOTA_IDLE+level2+showcase - appears to be the transition from level1 to level2?

function ai:TransitionToAggro()
    Debug('AiDruidsTower', 'Aggroing')

    self.state = ai.ACTION_AGGRO --State transition

    self:IncrementAggroCycle()

    -- self:ParticleOn()
    self:SetLook2()

    Timers(2, function()
        StartAnimation(self.aggroTarget, {
            duration = 9999, -- 2.5 hr limit...
            activity = ACT_DOTA_VICTORY,
        })
    end)

    Timers(4, function()
        local pIdx = ParticleManager:CreateParticle('particles/units/dark_plains/boss/energy_pull/energy_pull.vpcf', PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        -- attach_hitloc
        --local pIdx = ParticleManager:CreateParticle("particles/units/dark_plains/boss/energy_pull/energy_pull.vpcf", PATTACH_ROOTBONE_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(pIdx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(pIdx, 1, self.aggroTarget, PATTACH_POINT_FOLLOW, "attach_attack1", self.aggroTarget:GetAbsOrigin(), true)
        -- ParticleManager:SetParticleControl(pIdx, 1, self.aggroTarget:GetAbsOrigin() + Vector(0,0,300))
        self.energyLinkParticle = pIdx

        Timers(4, function()
            self:SetLook3()
        end)

        Timers(8, function()
            EndAnimation(self.aggroTarget)
            if self.energyLinkParticle then
                ParticleManager:DestroyParticle(self.energyLinkParticle, false)
                ParticleManager:ReleaseParticleIndex(self.energyLinkParticle)
                self.energyLinkParticle = nil
            end
        end)
    end)

    do return end

    StartAnimation(self:GetParent(), {
        duration = 9999, -- 2.5 hr limit...
        activity = ACT_DOTA_CAPTURE,
        rate = 1.0,
        translate = self.activityLevel,
    })

    Timers(2.0, function()
        self:IncrementAggroCycle()
        print('Bump to: ', self.activityLevel)

        EndAnimation(self:GetParent())
        -- self:ModPurge()
        Timers(0.25, function()
            StartAnimation(self:GetParent(), {
                duration = 9999, -- 2.5 hr limit...
                activity = ACT_DOTA_CAPTURE,
                rate = 0.15,
                translate = self.activityLevel,
            })
        end)

        if self.aggroCycle < 6 then return 3 end
    end)
end

function ai:TransitionToReturn()
    -- Remove aggro target.
    self.aggroTarget = nil

    -- self:SetStackCount(0)

    --self:GetParent():StartGesture(ACT_DOTA_IDLE)
    self:ParticleOff()
    self:GetParent():StartGesture(ACT_DOTA_ATTACK)

    -- Remove all negative modifiers.
    self:ModPurge() -- Also removes activity modifiers!
    self.state = ai.ACTION_IDLE --Transition the state to the 'Returning' state(!)
    --self.returnTicks = 0
    Timers(2, function() self:SetLook1() end)

    Debug('AiDruidsTower', 'Returning to Idle')
end


function ai:TransitionToIdle()
    self.state = ai.ACTION_IDLE

    self:GetParent():StartGesture(ACT_DOTA_IDLE)

    Debug('AiDruidsTower', 'Idling')
end



-----------------------------------------------------------------------------

function ai:IsHidden()
    return true
end

function ai:CheckState()
    return {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_STUNNED] = true,
    }
end

function ai:GetModifierHealthRegenPercentage()
    if self.state == ai.ACTION_AGGRO then return 0.0 end
    return 20.0
end

function ai:GetModifierConstantHealthRegen()
    if self.state == ai.ACTION_AGGRO then return 0.0 end
    -- print(self:GetParent():GetUnitName(), self.passiveHealthRegen)
    return self.passiveHealthRegen
end

function ai:OnAttackAllied(event)
    Debug('AiDruidsTower', 'OnAttackAllied PRE')
    if self:GetParent() ~= event.target then return end
    Debug('AiDruidsTower', 'OnAttackAllied')
end

function ai:OnTakeDamage(event)
    if self:GetParent() ~= event.unit then return end

    if self.state == ai.ACTION_IDLE then
        self:GetParent():MoveToTargetToAttack( event.attacker ) --Start attacking
        self.aggroTarget = event.attacker
        self.state = ai.ACTION_AGGRO --State transition
        Debug('AiDruidsTower', 'Aggroing')
    end
end

function ai:OnDeath(event)
    if self:GetParent() ~= event.unit then return end
    Debug('AiDruidsTower', 'OnDeath')
    self:GetParent().spawn:OnDeath(self)
end

function ai:OnIntervalThink()
    Dynamic_Wrap(ai, self.state)(self)
end

function ai:ActionIdle()
    local units = FindUnitsInRadius(
    self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil,
    self.detectRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER, false
    )
    --If one or more units were found, start attacking the first one
    if #units > 0 then
        self.aggroTarget = units[1]
        self:TransitionToAggro()
        return true
    end
end

function ai:ActionAggro()
    --Check if the unit has walked outside its detect range
    if ( self.aggroTarget:GetAbsOrigin() - self:GetParent():GetAbsOrigin() ):Length() > self.detectRange then
        self:TransitionToReturn()
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


----------
-- Doesn't work
--

function ai:TryToSetMaterials()
    -- Green 4, Black 6
    --self:GetParent():SetMaterialGroup('radiant_level4')

    -- function Wearables:HideDefaultWearables( event )
    --   local hero = event.caster
    --   local ability = event.ability

    --   hero.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
    --     local model = hero:FirstMoveChild()
    --     while model ~= nil do
    --         if model:GetClassname() == "dota_item_wearable" then
    --             model:AddEffects(EF_NODRAW) -- Set model hidden
    --             table.insert(hero.hiddenWearables, model)
    --         end
    --         model = model:NextMovePeer()
    --     end
    -- end
    local model = self:GetParent():FirstMoveChild()
    --print(model) -- Returns nil
    while model ~= nil do
        print('Found: ', model:GetClassname())
        print('Has: ', model.SetMaterialGroup)
        model = model:NextMovePeer()
    end
    -- function Wearables:ShowDefaultWearables( event )
    --   local hero = event.caster

    --   for i,v in pairs(hero.hiddenWearables) do
    --     v:RemoveEffects(EF_NODRAW)
    --   end
    -- end
end

