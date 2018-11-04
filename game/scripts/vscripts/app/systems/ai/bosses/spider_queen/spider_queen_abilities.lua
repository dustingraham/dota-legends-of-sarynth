--SpiderQueen = SpiderQueen or class({}, nil, AiBase)
local ai = SpiderQueen
if not ai then error('Must require main first.') end

function ai:SummonWolfSpider()
    self.isBusy = true
    self:Debug('Summon Wolf Spiders')

    local caster = self:GetEntity()

    -- Stop moving/attacking and start animation.
    EmitSoundOn('death_prophet_dpro_laugh_012', caster)
    caster:Stop()
    StartAnimation(self:GetEntity(), {
        duration = 1.8,
        activity = ACT_DOTA_CAST_ABILITY_2,
        rate = 0.6,
    })

    Timers(1.3, function()
        local spider = self:CreateSpider()
        table.insert(self.spiders, spider)
    end)

    Timers(1.8, function()
        self:Debug('Done, continue attacking.')

        self.timeSinceSummon = 0
        self.isBusy = false
    end)
end

function ai:CreateSpider()
    self:Debug('Create Spider')

    --self.spidersCreated = true
    local target = self.aggroTarget
    local caster = self:GetEntity()

    --local position = Entities:FindByName(nil, 'spawn_dark_caster_summon'):GetAbsOrigin() + RandomVector(50)
    local position = caster:GetAbsOrigin() + RandomVector(320)

    local pid = ParticleManager:CreateParticle('particles/units/webbed/spider_spawn_poof.vpcf',
        PATTACH_CUSTOMORIGIN,
        self:GetEntity())
    ParticleManager:SetParticleControl(pid, 0, position)

    local spider = CreateUnitByName('webbed_spidy_elder', position, true, caster, caster, caster:GetTeamNumber())
    spider:MoveToTargetToAttack(self.aggroTarget)
    Timers(1.0, function()
        if IsValidEntity(spider) then
            spider:MoveToTargetToAttack(target)
        end
    end)
    return spider
end

function ai:ExecutePoisonBloom()
    self.isBusy = true
    self:Debug('Execute Poison Bloom')

    local caster = self:GetEntity()
    local spellRadius = 700
    local targetLocation = self:GetEntity():GetAbsOrigin()

    -- Stop moving/attacking and start animation.
    caster:Stop()
    StartAnimation(caster, {
        duration = 5.0,
        activity = ACT_DOTA_CAST_ABILITY_4,
        rate = 0.15,
    })

    -- Warning Indicator
    local targetingParticle = ParticleManager:CreateParticle('particles/targeting/aoe_danger.vpcf',
        PATTACH_CUSTOMORIGIN,
        self:GetEntity())
    ParticleManager:SetParticleControl(targetingParticle, 0, targetLocation)
    ParticleManager:SetParticleControl(targetingParticle, 1, Vector(spellRadius, 0, 0))
    Timers(6.5, function()
        -- Stop the particle...
        ParticleManager:DestroyParticle(targetingParticle, false)
        ParticleManager:ReleaseParticleIndex(targetingParticle)
    end)

    -- Poison Cloud and Damage Bursts
    Timers(2, function()
        -- Burn
        local noxiousParticle = ParticleManager:CreateParticle('particles/units/webbed/noxious_cloud.vpcf',
            PATTACH_CUSTOMORIGIN,
            self:GetEntity())
        ParticleManager:SetParticleControl(noxiousParticle, 0, targetLocation)
        ParticleManager:SetParticleControl(noxiousParticle, 1, Vector(spellRadius * 1.3, 0, 0))
        local bursts = 0
        Timers(1.5, function()
            -- Find and damage heroes
            self:DamageRadius({
                position = targetLocation,
                radius = spellRadius,
                damage = math.random(1700, 2200),
                damageType = DAMAGE_TYPE_PURE
            })
            bursts = bursts + 1
            if bursts < 5 then return 0.75 end
        end)

        Timers(4, function()
            -- Takes 2 seconds to stop, so can stop 2 seconds early.
            -- Stop the particle...
            ParticleManager:DestroyParticle(noxiousParticle, false)
            ParticleManager:ReleaseParticleIndex(noxiousParticle)
        end)
    end)

    -- Once 5 second animation is done, proceed to attack again.
    Timers(5.0, function()
        self:Debug('Done with cast animation, start moving to attack.')
        self.timeSinceBloom = 0
        self.isBusy = false
    end)
end

function ai:FireTriplicate()
    self.isBusy = true
    self:Debug('[Action] Triple Poison')

    local caster = self:GetEntity()
    caster:Stop()

    caster:FaceTowards(self.aggroTarget:GetAbsOrigin())

    -- Create Particle For Everyone
    local targetPoint = self.aggroTarget:GetAbsOrigin()
    self:MakeLine({
        length = 1600,
        width = 120,
        duration = 2.4,
        targetPoint = targetPoint
    })

    Timers(1.7, function()
        if caster:IsNull() then return end
        StartAnimation(caster, {
            duration = 1.2,
            activity = ACT_DOTA_CAST_ABILITY_1,
            rate = 1.0,
        })
        Timers(1.2, function()
            self.isBusy = false
        end)

        for i = 0, 2, 1 do
            Projectile({
                owner = caster,
                target = self.aggroTarget,
                targetPoint = targetPoint,
                speed = 1000 + 400 * i,
                distance = 800 + 400 * i,
                width = 120,
                damage = 1000,
                graphics = "particles/testing/venomancer_venomous_gale_concept.vpcf",
                onHit = function(projectile, target)
                    ApplyDamage({
                        victim = target,
                        attacker = caster,
                        damage = math.random(1700, 2200),
                        damage_type = DAMAGE_TYPE_PURE
                    })
                end
            }):Activate()
        end
    end)
end
