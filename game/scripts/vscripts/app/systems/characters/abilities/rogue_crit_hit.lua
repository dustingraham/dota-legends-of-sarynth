rogue_crit_hit = rogue_crit_hit or class({})

local spell = rogue_crit_hit

 
POPUP_SYMBOL_PRE_PLUS = 0
POPUP_SYMBOL_PRE_MINUS = 1
POPUP_SYMBOL_PRE_SADFACE = 2
POPUP_SYMBOL_PRE_BROKENARROW = 3
POPUP_SYMBOL_PRE_SHADES = 4
POPUP_SYMBOL_PRE_MISS = 5
POPUP_SYMBOL_PRE_EVADE = 6
POPUP_SYMBOL_PRE_DENY = 7
POPUP_SYMBOL_PRE_ARROW = 8

POPUP_SYMBOL_POST_EXCLAMATION = 0
POPUP_SYMBOL_POST_POINTZERO = 1
POPUP_SYMBOL_POST_MEDAL = 2
POPUP_SYMBOL_POST_DROP = 3
POPUP_SYMBOL_POST_LIGHTNING = 4
POPUP_SYMBOL_POST_SKULL = 5
POPUP_SYMBOL_POST_EYE = 6
POPUP_SYMBOL_POST_SHIELD = 7
POPUP_SYMBOL_POST_POINTFIVE = 8

function spell:OnSpellStart()
    print('[SPELL] Starting rogue_crit_hit')
    
    local caster = self:GetCaster()
    -- caster:AddNewModifier(caster, self, 'modifier_boss_alpha_test_1', { duration = 10 })
    
    -- Test Damage Deal
    local target = self:GetCursorTarget()
    local damage = 3150
    ApplyDamage({ victim = target, attacker = caster, damage = damage,  damage_type = DAMAGE_TYPE_MAGICAL })
    
    ScreenShake(caster:GetAbsOrigin(), 5, 150, 0.45, 3000, 0, true)
    
    local amount = damage
    -- PopupNumbers(target, "damage", Vector(255, 0, 0), 1.0, amount, nil, POPUP_SYMBOL_POST_DROP)
    --PopupNumbers(target, "crit", Vector(255, 0, 0), 5.0, amount, nil, POPUP_SYMBOL_POST_LIGHTNING)
    
    -- PopupDamageBlock(caster, 100)
    
--    PopupExperience(caster, 248)
--    PopupCriticalDamage(target, 1337)
--    PopupHPRemovalDamage(caster, 999)
    
    PopupMana(caster, 1233)
    PopupMana(target, 1033)
    
--    for i=1,10 do
--        PopupDamage(target, 999)
--        PopupCriticalDamage(target, 1337)
--    end
--    
    local i = 0
    Timers:CreateTimer(function()
        i = i + 1
        if i > 60 then return nil end
        if i % 2 == 0 then
            PopupCriticalDamage(caster, 1337)
        else
    PopupMana(caster, 1233)
    PopupMana(target, 1033)
--            PopupDamage(caster, 999)
        end
        return 0.20
    end)
    
    --PopupFirstAid(caster)
    --PopupHealing(caster, 1337)
    
    -- caster:SetCustomHealthLabel(nil,128,0,0)
    
    ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf", PATTACH_ABSORIGIN, caster)
    EmitSoundOn('Hero_Sven.GodsStrength', caster)
    
    -- ParticleManager:CreateParticle("particles/status_effect_experimental_fire.vpcf", PATTACH_ABSORIGIN, caster)
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_decrepify.vpcf", PATTACH_ABSORIGIN, caster)
    Timers:CreateTimer(3, function()
        ParticleManager:DestroyParticle(particle, true)
        ParticleManager:ReleaseParticleIndex(particle)
    end)
end


-- e.g. when healed by an ability
--function PopupHealing(target, amount)
--    amount = math.floor(amount)
--    PopupNumbers(target, "heal", Vector(0, 255, 0), 1.3, amount, POPUP_SYMBOL_PRE_PLUS, nil)
--end
--
--function PopupFirstAid(target)
--
--    local pfx = "heal"
--    local color = Vector(255, 10, 0)
--    local lifetime = 2
--    presymbol = POPUP_SYMBOL_PRE_PLUS
--    postsymbol = nil
--    local pfxPath = string.format("particles/msg_fx/msg_%s.vpcf", pfx)
--    local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_OVERHEAD_FOLLOW, target) -- target:GetOwner()
--
--    local digits = 0
--    if number ~= nil then
--        digits = #tostring(number)
--    end
--    if presymbol ~= nil then
--        digits = digits + 1
--    end
--    if postsymbol ~= nil then
--        digits = digits + 1
--    end
--
--    ParticleManager:SetParticleControl(pidx, 1, Vector(tonumber(presymbol), tonumber(0), tonumber(postsymbol)))
--    ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, 1, 20))
--    ParticleManager:SetParticleControl(pidx, 3, color)
--end
--
--function PopupExperience(target, amount)
--    PopupNumbers(target, "miss", Vector(124, 46, 254), 2.5, amount, POPUP_SYMBOL_PRE_PLUS, nil)
--end
--
--function PopupDamageBlock(target, amount)
--    PopupNumbers(target, "block", Vector(255, 255, 255), 1.0, amount, POPUP_SYMBOL_PRE_MINUS, nil)
--end
--
--function PopupNumbers(target, pfx, color, lifetime, number, presymbol, postsymbol)
--    local pfxPath = string.format("particles/msg_fx/msg_%s.vpcf", pfx)
--    
--    -- local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, target) -- target:GetOwner()
--    local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_OVERHEAD_FOLLOW, target) -- target:GetOwner()
--    -- local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ROOTBONE_FOLLOW, target) -- target:GetOwner()
--    
--    local digits = 0
--    if number ~= nil then
--        digits = #tostring(number)
--    end
--    if presymbol ~= nil then
--        digits = digits + 1
--    end
--    if postsymbol ~= nil then
--        digits = digits + 1
--    end
--
--    ParticleManager:SetParticleControl(pidx, 1, Vector(tonumber(presymbol), tonumber(number), tonumber(postsymbol)))
--    ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
--    ParticleManager:SetParticleControl(pidx, 3, color)
--end


-- function spell:OnAbilityPhaseStart()
--     print('[spell] OnAbilityPhaseStart')
--  end
function spell:OnAbilityPhaseInterrupted()
    print('[spell] OnAbilityPhaseStart')
end
function spell:OnProjectileThink(vLocation)
    print('[spell] OnProjectileThink')
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
    return 1000
end




function rogue_crit_hit:GetAbilityCastPoint()
    print('Getting cast point...')
    return 1.0
end
