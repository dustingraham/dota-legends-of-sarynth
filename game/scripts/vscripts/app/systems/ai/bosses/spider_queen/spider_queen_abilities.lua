SpiderQueen = SpiderQueen or class({}, nil, AiBase)
local ai = SpiderQueen

function ai:SummonWolfSpider()
    self.isBusy = true
    self:Debug('Summon Wolf Spiders')

    StartAnimation(self:GetEntity(), {
        duration = 1.0,
        activity = ACT_DOTA_CAST_ABILITY_2,
        rate = 1.0,
    })

    -- Poof of smoke?
    self:CreateSpider()

    --Timers:CreateTimer(3.0, function()
    --    if self:IsNull() or self:GetParent():IsNull() then Debug('AiWebbedQueen', 'Too fast dead') return end
    --    Debug('AiWebbedQueen', 'Starting Attack')
    --    self:GetParent():MoveToTargetToAttack(self.aggroTarget)
    --end)

    Timers(3.0, function()
        self:Debug('Done? Release Busy?')

        self.timeSinceSummon = 0
        self.isBusy = false
    end)
end

function ai:CreateSpider()
    self:Debug('Create Spider')

    --self.spidersCreated = true
    local target = self.aggroTarget
    local boss = self:GetEntity()

    EmitSoundOn('death_prophet_dpro_laugh_012', boss)

    --local position = Entities:FindByName(nil, 'spawn_dark_boss_summon'):GetAbsOrigin() + RandomVector(50)
    local position = boss:GetAbsOrigin() + RandomVector(200)

    local spider = CreateUnitByName('webbed_spidy_elder', position, true, boss, boss, boss:GetTeamNumber())
    spider:MoveToTargetToAttack( self.aggroTarget )
    Timers(1.0, function()
        if IsValidEntity(spider) then
            spider:MoveToTargetToAttack( target )
        end
    end)
    return spider
end

function ai:ExecutePoisonBloom()
    self.isBusy = true
    self:Debug('Execute Poison Bloom')

    StartAnimation(self:GetEntity(), {
        duration = 1.0,
        activity = ACT_DOTA_CAST_ABILITY_4,
        rate = 1.0,
    })

    Timers(3.0, function()
        self:Debug('Done? Release Busy?')

        self.timeSinceBloom = 0
        self.isBusy = false
    end)
end
