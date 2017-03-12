simple_projectile = simple_projectile or class({})

local spell = simple_projectile

spell.target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
spell.target_type = DOTA_UNIT_TARGET_ALL
spell.target_flag = DOTA_UNIT_TARGET_FLAG_NONE


function GetHeroID( player )
    player = type( player ) == 'number' and PlayerResource:GetPlayer( player ) or player
    local hHero = player:GetAssignedHero()
    return hHero:GetEntityIndex()
end
function GetNetTable( table, key )
    key = tostring( key )
    local value = CustomNetTables:GetTableValue( table, key )
    -- print('Get', table, key, value)
    return CustomNetTables:GetTableValue( table, key )
end
function SetNetTable( table, key, value )
    key = tostring( key )
    value = type( value ) ~= 'table' and { value = value } or value
    print('Set', table, key, value)
    CustomNetTables:SetTableValue( table, key, value )
end

function GetUnitTarget(unit)
    -- local iUnit   = unit:GetEntityIndex()
    local value = GetNetTable( 'focus_target', unit:GetPlayerOwnerID() )
    if value and value.value then
        local target = EntIndexToHScript( value.value )
        if IsValidEntity( target ) then 
            return target
        end
    end
    
    return nil
end

function spell:OnAbilityPhaseStart()
    print('[SPELL] Pre-Check simple_projectile')
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    
--    local tteam = self:GetAbilityTargetTeam()
--    print('TTeam', tteam, tteam == self.target_team)
--    
    if not IsValidEntity(target) then
        print('APS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end
    
    local vectorDiff = target:GetAbsOrigin() - caster:GetAbsOrigin()
    print('Actual: ', vectorDiff:Length())
    print('Allowed: ', self:GetCastRange())
    
    if vectorDiff:Length() > self:GetCastRange() + 50 then
        print('[Distance] Too far fool')
        return false
    end
    
    return true
end

function spell:OnSpellStart()
    print('[SPELL] Starting simple_projectile')
    
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    
    if not IsValidEntity(target) then
        print('OSS IsValidEntity Failed!', IsValidEntity(target))
        return false
    end
    
    if (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length() > self:GetCastRange() then
        print('[Distance] We let this pass')
    end
    
    -- caster:AddNewModifier(caster, self, 'modifier_boss_alpha_test_1', { duration = 10 })
    
    -- Test Damage Deal
    -- local target = self:GetCursorTarget()
    -- ApplyDamage({ victim = target, attacker = caster, damage = damage,  damage_type = DAMAGE_TYPE_MAGICAL })

    local damage = 3150
    local amount = damage
    local projectile_speed = 2000
    local particle_name = 'particles/econ/items/abaddon/abaddon_alliance/abaddon_death_coil_alliance.vpcf'
    
    -- Create the projectile
    local info = {
        Target = target,
        Source = caster,
        Ability = self,
        EffectName = particle_name,
        bDodgeable = false,
        bProvidesVision = true,
        iMoveSpeed = projectile_speed,
        iVisionRadius = 0,
        iVisionTeamNumber = caster:GetTeamNumber(),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
    }
    ProjectileManager:CreateTrackingProjectile( info )
    
    FX(
        "particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_channel_ti6_shock_ring.vpcf",
        PATTACH_ABSORIGIN,
        caster,
        {
            cp1 = { ent = caster, attach = PATTACH_ABSORIGIN },
            release = true
        }
    )
    
    PopupMana(caster, 1233)
    
    ScreenShake(caster:GetAbsOrigin(), 5, 150, 0.45, 3000, 0, true)
    ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf", PATTACH_ABSORIGIN, caster)
    
end


-- function spell:OnAbilityPhaseStart()
--     print('[spell] OnAbilityPhaseStart')
--  end
function spell:OnAbilityPhaseInterrupted()
    print('[spell] OnAbilityPhaseStart')
end
function spell:OnProjectileThink(vLocation)
    -- print('[spell] OnProjectileThink')
end
function spell:OnProjectileHit(hTarget, vLocation)
    print('[spell] OnProjectileHit')
end
function spell:OnChannelFinish(bInterrupted)
    print('[spell] OnChannelFinish')
end
function spell:OnUpgrade()
    print('[spell] OnUpgrade')
end

function spell:GetCastRange()
    return 600
end




function spell:GetAbilityCastPoint()
    print('Getting cast point...')
    return 1.0
end

function FX(path, attach, parent, options)
    if parent and parent.GetUnit then
        parent = parent:GetUnit()
    end

    local index = ParticleManager:CreateParticle(path, attach, parent)

    for i = 0, 16 do
        local cp = options["cp"..tostring(i)]
        local cpf = options["cp"..tostring(i).."f"]

        if cp then
            -- Probably vector
            if type(cp) == "userdata" then
                ParticleManager:SetParticleControl(index, i, cp)
            end

            -- Entity
            if type(cp) == "table" then
                if cp.ent and cp.ent.GetUnit then
                    cp.ent = cp.ent:GetUnit()
                end

                if not cp.attach then
                    cp.attach = PATTACH_POINT_FOLLOW
                end

                ParticleManager:SetParticleControlEnt(index, i, cp.ent, cp.attach, cp.point, cp.ent:GetAbsOrigin(), true)
            end
        end

        if cpf then
            ParticleManager:SetParticleControlForward(index, i, cpf)
        end
    end

    if options.release then
        ParticleManager:ReleaseParticleIndex(index)
    else
        return index
    end
end




if IsClient() then
    require('app/systems/characters/abilities/wrappers')
end

Wrappers.FocusTargetAbility(simple_projectile)
