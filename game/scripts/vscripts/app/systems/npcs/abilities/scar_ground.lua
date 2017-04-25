scar_ground = scar_ground or class({})
local spell = scar_ground

function spell:OnAbilityPhaseStart()
    StartAnimation(self:GetCaster(), {
        duration = 5.0,
        --activity = ACT_DOTA_FLAIL,
        --rate = 1.2
        activity = ACT_DOTA_ATTACK,
        rate = 0.4
    })

    --local position = self:GetCursorPosition()
    --print(position)
    EmitSoundOn('Hero_Lycan.SummonWolves', self:GetCaster())

    --self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin()+Vector(0,0,60))
    return true
end

function spell:OnAbilityPhaseInterrupted()
    EndAnimation(self:GetCaster())
    --self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin()-Vector(0,0,60))
end

function spell:OnSpellStart()
    EndAnimation(self:GetCaster())
    --self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin()-Vector(0,0,60))
    --local caster = self:GetCaster()
    --local position = self:GetCursorTarget()
    local position = self:GetCursorPosition()
    --print(position)
    local ticks        = 0
    --local position = self:GetParent():GetAbsOrigin()
    --local entity       = CreateUnitByName('webbed_spidy_bubble_death', position, true, nil, nil, DOTA_TEAM_NEUTRALS)

    -- Ground Visual
    local scarParticle = ParticleManager:CreateParticle('particles/units/start/scar/scar_ground/scar_ground.vpcf', PATTACH_CUSTOMORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl( scarParticle, 0, position )
    -- ParticleManager:SetParticleControl( scarParticle, 1, self:GetCaster():GetForwardVector() )

    -- Damaged Ground
    Timers:CreateTimer(1.25, function()
        ticks = ticks + 1
        if not self:GetCaster():IsNull() and self:GetCaster():IsAlive() and Encounter.InEncounter then
            -- Make the ouch
            local units = FindUnitsInRadius(
            DOTA_TEAM_GOODGUYS,
            position,
            nil,
            150,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
            )
            for _,ouchUnit in pairs(units) do
                ouchUnit:AddNewModifier(self:GetCaster(), self, 'scar_ground_pain', { duration = 3 })
            end
            return 1
        else
            -- Stop the particle...
            ParticleManager:DestroyParticle(scarParticle, false)
            ParticleManager:ReleaseParticleIndex(scarParticle)

            -- Delay to destroy the entity, otherwise particle clips off.
            --Timers(3, function()
            --    -- TODO: Create a single global dummy entity.
            --    entity:ForceKill(false)
            --end)
        end
    end)



    --
    --local damage = math.floor(caster:GetAverageTrueAttackDamage(target) * 0.85)
    --
    --local targets = FindUnitsInRadius(
    --target:GetTeamNumber(), caster:GetAbsOrigin(),
    --nil, 300,
    --DOTA_UNIT_TARGET_TEAM_FRIENDLY,
    --DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    --DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    --for _,coTarget in pairs(targets) do
    --    ApplyDamage({
    --                    victim = coTarget,
    --                    attacker = caster,
    --                    damage = damage,
    --                    damage_type = DAMAGE_TYPE_MAGICAL
    --                })
    --    coTarget:AddNewModifier(caster, self, 'kobold_boss_slammed', { duration = 2 })
    --end
    --
    --local particle = ParticleManager:CreateParticle(
    --'particles/units/heroes/hero_ursa/ursa_earthshock.vpcf',
    --PATTACH_ABSORIGIN,
    --caster
    --)
    --ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
    --ParticleManager:ReleaseParticleIndex(particle)

    -- EmitSoundOn('Creep_Good_Melee.PreAttack', caster)
    EmitSoundOn('Hero_EarthShaker.Totem.Attack', target)
end

function spell:GetCastRange()
    return 150
end
function spell:GetMaxLevel()
    return 1
end

LinkLuaModifier('scar_ground_pain', 'app/systems/npcs/abilities/scar_ground', LUA_MODIFIER_MOTION_NONE)

scar_ground_pain = scar_ground_pain or class({})
local mod = scar_ground_pain

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
    return 'npcs/scar_ground'
end

function mod:OnCreated(kv)
    if IsServer() then
        self:SetStackCount(1)
        self.lastDamageTick = math.random(50, 70)
        ApplyDamage({
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = self.lastDamageTick,
            damage_type = DAMAGE_TYPE_MAGICAL
        })
        PopupBleed(self:GetParent(), self.lastDamageTick)
    end
end

function mod:OnRefresh(kv)
    -- print('Is Server: ', IsServer())
    if IsServer() then
        -- print('Modifier Parent: ', self:GetParent():GetName())
        -- print('Modifier Caster: ', self:GetCaster():GetName())
        self:IncrementStackCount()
        self.lastDamageTick = self.lastDamageTick + math.random(10, 20)
        ApplyDamage({
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            --damage = self:GetStackCount() * math.random(20,40),
            damage = self.lastDamageTick,
            damage_type = DAMAGE_TYPE_MAGICAL
        })
        PopupBleed(self:GetParent(), self.lastDamageTick)
    end
end
