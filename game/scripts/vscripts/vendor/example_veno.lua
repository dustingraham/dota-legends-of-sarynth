-------------------------------------------
-- From FireToad
--
--            VENOMOUS GALE
-------------------------------------------
LinkLuaModifier("modifier_imba_venomous_gale", "hero/hero_venomancer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_venomous_gale_wardcast", "hero/hero_venomancer", LUA_MODIFIER_MOTION_NONE)

imba_venomancer_venomous_gale = class({})
function imba_venomancer_venomous_gale:IsHiddenWhenStolen() return false end
function imba_venomancer_venomous_gale:IsRefreshable() return true end
function imba_venomancer_venomous_gale:IsStealable() return true end
function imba_venomancer_venomous_gale:IsNetherWardStealable() return true end

function imba_venomancer_venomous_gale:GetAbilityTextureName()
    return "venomancer_venomous_gale"
end
-------------------------------------------

function imba_venomancer_venomous_gale:GetCastRange( location , target)
    local range = self:GetSpecialValueFor("cast_range")
    if IsServer() then
        local caster = self:GetCaster()
        if (caster:GetAbsOrigin() - location):Length2D() <= (range + GetCastRangeIncrease(caster)) then
            self.bWardCaster = nil
            return range
        end
        local ward_range = self:GetSpecialValueFor("ward_range") + GetCastRangeIncrease(caster)
        local wards = FindUnitsInRadius(caster:GetTeamNumber(), location, nil, ward_range, DOTA_UNIT_TARGET_TEAM_FRIENDLY,  DOTA_UNIT_TARGET_OTHER, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
        for _, ward in pairs(wards) do
            if ward.bIsScourge then
                self.bWardCaster = ward
                return 25000
            end
        end
        self.bWardCaster = nil
    end
    return range
end

function imba_venomancer_venomous_gale:GetCastAnimation()
    if self.bWardCaster then
        return 0
    else
        return ACT_DOTA_CAST_ABILITY_1
    end
end

function imba_venomancer_venomous_gale:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        local target_loc = self:GetCursorPosition()
        local caster_loc

        local mouth_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_venomancer/venomancer_venomous_gale_mouth.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        if self.bWardCaster then
            caster_loc = self.bWardCaster:GetAbsOrigin()
            ParticleManager:SetParticleControlEnt(mouth_pfx, 0, self.bWardCaster, PATTACH_POINT_FOLLOW, "attach_attack1", self.bWardCaster:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(mouth_pfx)
            self.bWardCaster:AddNewModifier(caster, self, "modifier_imba_venomous_gale_wardcast", {duration = 0.4})
            self.bWardCaster:FadeGesture(ACT_DOTA_ATTACK)
            self.bWardCaster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 2.3)
            self.bWardCaster:SetForwardVector((target_loc - caster_loc):Normalized())
        else
            caster_loc = caster:GetAbsOrigin()
            ParticleManager:SetParticleControlEnt(mouth_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_mouth", caster:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(mouth_pfx)
        end

        -- Parameters
        local duration = self:GetSpecialValueFor("duration")
        local strike_damage = self:GetSpecialValueFor("strike_damage")
        local tick_damage = self:GetSpecialValueFor("tick_damage")
        local tick_interval = self:GetSpecialValueFor("tick_interval")
        local radius = self:GetSpecialValueFor("radius")
        local projectile_speed = self:GetSpecialValueFor("speed")

        local direction
        if target_loc == caster_loc then
            direction = caster:GetForwardVector()
        else
            direction = (target_loc - caster_loc):Normalized()
        end
        local index = DoUniqueString("index")
        self[index] = {}
        local travel_distance
        caster:EmitSound("Hero_Venomancer.VenomousGale")

        local projectile_count = 1
        if caster:HasTalent("special_bonus_imba_venomancer_7") then
            projectile_count = caster:FindTalentValue("special_bonus_imba_venomancer_7")
        end

        ParticleManager:SetParticleControlEnt(mouth_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_mouth", caster:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(mouth_pfx)

        for i = 1, projectile_count, 1 do
            local angle = 360 - (360 / projectile_count)*i
            local velocity = RotateVector2D(direction,angle,true)
            local projectile
            if self.bWardCaster then
                travel_distance = self:GetSpecialValueFor("ward_range") + GetCastRangeIncrease(caster)
                projectile =
                {
                    Ability				= self,
                    EffectName			= "particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf",
                    vSpawnOrigin		= self.bWardCaster:GetAbsOrigin(),
                    fDistance			= travel_distance,
                    fStartRadius		= radius,
                    fEndRadius			= radius,
                    Source				= caster,
                    bHasFrontalCone		= true,
                    bReplaceExisting	= false,
                    iUnitTargetTeam		= self:GetAbilityTargetTeam(),
                    iUnitTargetFlags	= self:GetAbilityTargetFlags(),
                    iUnitTargetType		= self:GetAbilityTargetType(),
                    fExpireTime 		= GameRules:GetGameTime() + 10.0,
                    bDeleteOnHit		= true,
                    vVelocity			= Vector(velocity.x,velocity.y,0) * projectile_speed,
                    bProvidesVision		= false,
                    ExtraData			= {index = index, strike_damage = strike_damage, duration = duration, projectile_count = projectile_count}
                }
            else
                travel_distance = self.BaseClass.GetCastRange(self,target_loc,nil) + GetCastRangeIncrease(caster)
                projectile =
                {
                    Ability				= self,
                    EffectName			= "particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf",
                    vSpawnOrigin		= caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_mouth")),
                    fDistance			= travel_distance,
                    fStartRadius		= radius,
                    fEndRadius			= radius,
                    Source				= caster,
                    bHasFrontalCone		= true,
                    bReplaceExisting	= false,
                    iUnitTargetTeam		= self:GetAbilityTargetTeam(),
                    iUnitTargetFlags	= self:GetAbilityTargetFlags(),
                    iUnitTargetType		= self:GetAbilityTargetType(),
                    fExpireTime 		= GameRules:GetGameTime() + 10.0,
                    bDeleteOnHit		= true,
                    vVelocity			= Vector(velocity.x,velocity.y,0) * projectile_speed,
                    bProvidesVision		= false,
                    ExtraData			= {index = index, strike_damage = strike_damage, duration = duration, projectile_count = projectile_count}
                }
            end
            ProjectileManager:CreateLinearProjectile(projectile)
        end
    end
end

function imba_venomancer_venomous_gale:OnProjectileHit_ExtraData(target, location, ExtraData)
    local caster = self:GetCaster()
    if target then
        local was_hit = false
        for _, stored_target in ipairs(self[ExtraData.index]) do
            if target == stored_target then
                was_hit = true
                break
            end
        end
        if was_hit then
            return nil
        else
            table.insert(self[ExtraData.index],target)
        end
        ApplyDamage({victim = target, attacker = caster, ability = self, damage = ExtraData.strike_damage, damage_type = self:GetAbilityDamageType()})
        target:AddNewModifier(caster, self, "modifier_imba_venomous_gale", {duration = ExtraData.duration})
        target:EmitSound("Hero_Venomancer.VenomousGaleImpact")
    else
        self[ExtraData.index]["count"] = self[ExtraData.index]["count"] or 0
        self[ExtraData.index]["count"] = self[ExtraData.index]["count"] + 1
        if self[ExtraData.index]["count"] == ExtraData.projectile_count then
            if (#self[ExtraData.index] > 0) and (caster:GetName() == "npc_dota_hero_venomancer") then
                caster:EmitSound("venomancer_venm_cast_0"..math.random(1,2))
            end
            self[ExtraData.index] = nil
        end
    end
end
