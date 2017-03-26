---
-- Specifically designed for start boss. To be refactored into a generic encounter.
--
-- @type Encounter
Encounter = Encounter or class({})

function Encounter:Activate()
    Event:Listen('HeroDeath', Dynamic_Wrap(Encounter, 'OnHeroDeath'), self)
    ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(Encounter, 'OnAbilityUsed'), self)
end

function Encounter:Start(boss, hero)
    Debug('Encounter', 'Starting encounter')
    self.boss = boss
    self.hero = hero -- TODO : ONE FOR NOW...
    self.logs = {}
    self.startTime = GameRules:GetGameTime()
    self.InEncounter = true

    self:Log('Hero: '..hero:GetName())
    self:Log('Level: '..hero:GetLevel())
    for _,item in pairs(hero.customEquipment:GetAllItems()) do
        self:Log('Equipment: '..item:GetName())
    end
    self:Log('TrueDmg: '..hero:GetAverageTrueAttackDamage(boss))

    self:LogBothHp('Started at '..math.ceil(self.startTime))
    --self:LogBothHp()

    local relay = Entities:FindByName(nil, 'start_area_barricade_relay_on')
    relay:Trigger()
    self:MoveBlockers(219.125)
end

function Encounter:End()
    Debug('Encounter', 'Ending encounter')
    self.InEncounter = false

    self:LogBothHp('Ended at '..math.ceil(GameRules:GetGameTime()))
    -- self:LogBothHp()

    local relay = Entities:FindByName(nil, 'start_area_barricade_relay_off')
    relay:Trigger()
    self:MoveBlockers(-219.125)
    self:Report()
end

function Encounter:Report()
    print('TODO: Report Encounter')
    DeepPrintTable(self.logs)
end
function Encounter:LogBothHp(eventName)
    --self:LogHp(self.hero, 'hero')
    --self:LogHp(self.boss, 'boss')
    local bosshp = string.format("%10s ",self.boss:GetHealth()..'/'..self.boss:GetMaxHealth())
    local herohp = string.format("%10s ",self.hero:GetHealth()..'/'..self.hero:GetMaxHealth())
    Encounter:Log('Health: '..bosshp..' Hero: '..herohp.. ' Event: '..eventName)
end
function Encounter:LogHp(target, name)
    -- target:GetName()
    Encounter:Log(name..' HP: '..target:GetHealth()..'/'..target:GetMaxHealth())
end
function Encounter:Log(str)
    local timeElapsed = math.ceil(GameRules:GetGameTime() - self.startTime)
    timeElapsed = string.format("%4s ",timeElapsed)
    table.insert(self.logs, '['..timeElapsed..'] '..str)
end

function Encounter:MoveBlockers(distance)
    local blockers = Entities:FindAllByName('start_area_barricade_wall')
    -- 40 intervals
    local d = distance / 40
    local i = 0
    local total = 0
    Timers:CreateTimer(function()
        for _,blocker in pairs(blockers) do
            blocker:SetAbsOrigin(blocker:GetAbsOrigin()+Vector(0,0,d))
        end
        total = total + d
        i = i + 1
        if i > 40 then
            print(total)
            return nil
        end
        return 0.03
    end)
end

function Encounter:OnHeroDeath(e, event)
    Debug('Encounter', 'Hero died, ending encounter.')
    local hero = event.hero
    if self.InEncounter then
        self:End()
    end
end

function Encounter:OnAbilityUsed(event)
    if not self.InEncounter then return end
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
    -- hero:GetName()
    self:LogBothHp(event.abilityname)
    --self:Log('hero used ability: '..event.abilityname)
    --self:LogBothHp()
end

Event:BindActivate(Encounter)
