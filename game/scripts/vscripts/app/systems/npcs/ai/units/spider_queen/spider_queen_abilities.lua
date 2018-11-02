ai_spider_queen = ai_spider_queen or class({}, nil, ai_core)
local ai = ai_spider_queen

function ai:SummonWolfSpider()
    self.isBusy = true
    self:Debug('Summon Wolf Spiders')

    StartAnimation(self:GetParent(), {
        duration = 1.0,
        activity = ACT_DOTA_CAST_ABILITY_2,
        rate = 1.0,
    })

    -- Poof of smoke?

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

function ai:ExecutePoisonBloom()
    self.isBusy = true
    self:Debug('Execute Poison Bloom')

    StartAnimation(self:GetParent(), {
        duration = 1.0,
        activity = ACT_DOTA_CAST_ABILITY_4,
        rate = 1.0,
    })

    Timers(3.0, function()
        self:Debug('Done? Release Busy?')

        self.timeSinceSummon = 0
        self.isBusy = false
    end)
end
